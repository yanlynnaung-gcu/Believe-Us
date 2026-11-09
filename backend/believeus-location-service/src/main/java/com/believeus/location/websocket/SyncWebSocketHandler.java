package com.believeus.location.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
public class SyncWebSocketHandler extends TextWebSocketHandler {

    private final ObjectMapper objectMapper;
    private final CoupleEventPublisher coupleEventPublisher;

    // session.getId() -> WebSocketSession
    private final Map<String, WebSocketSession> activeSessions = new ConcurrentHashMap<>();

    // userId -> session.getId()
    private final Map<String, String> userSessionMap = new ConcurrentHashMap<>();

    // session.getId() -> userId
    private final Map<String, String> sessionUserMap = new ConcurrentHashMap<>();

    // session.getId() -> coupleSpaceId
    private final Map<String, String> sessionSpaceMap = new ConcurrentHashMap<>();

    // session.getId() -> Set of subscribed topic strings (e.g., "/topic/couple.{id}.*")
    private final Map<String, Set<String>> sessionTopicsMap = new ConcurrentHashMap<>();

    public SyncWebSocketHandler(
            ObjectMapper objectMapper,
            @Lazy CoupleEventPublisher coupleEventPublisher) {
        this.objectMapper = objectMapper;
        this.coupleEventPublisher = coupleEventPublisher;
    }

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        activeSessions.put(session.getId(), session);
        sessionTopicsMap.put(session.getId(), ConcurrentHashMap.newKeySet());
        log.info("[WS Connected] Session ID: {}, Remote: {}", session.getId(), session.getRemoteAddress());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) {
        try {
            String payload = message.getPayload();
            @SuppressWarnings("unchecked")
            Map<String, Object> json = objectMapper.readValue(payload, Map.class);
            String action = (String) json.get("action");

            if ("SUBSCRIBE".equalsIgnoreCase(action) || "SUBSCRIBE_TOPIC".equalsIgnoreCase(action)) {
                String userId = (String) json.get("userId");
                String spaceId = (String) json.get("coupleSpaceId");
                String explicitTopic = (String) json.get("topic");

                Set<String> topics = sessionTopicsMap.computeIfAbsent(session.getId(), k -> ConcurrentHashMap.newKeySet());

                if (userId != null && !userId.isBlank()) {
                    userSessionMap.put(userId, session.getId());
                    sessionUserMap.put(session.getId(), userId);
                    log.info("[WS Subscribed User] User: '{}' mapped to Session '{}'", userId, session.getId());
                }

                if (spaceId != null && !spaceId.isBlank()) {
                    sessionSpaceMap.put(session.getId(), spaceId);
                    // Automatically subscribe to isolated dynamic couple room topics
                    String basePattern = "/topic/couple." + spaceId + ".*";
                    topics.add(basePattern);
                    topics.add("/topic/couple." + spaceId + ".chat");
                    topics.add("/topic/couple." + spaceId + ".location");
                    topics.add("/topic/couple." + spaceId + ".gifts");
                    topics.add("/topic/couple." + spaceId + ".status");
                    topics.add("/topic/couple." + spaceId + ".milestones");
                    log.info("[WS Subscribed Dynamic Space Room] Session '{}' subscribed to: {}", session.getId(), basePattern);
                }

                if (explicitTopic != null && !explicitTopic.isBlank()) {
                    topics.add(explicitTopic.trim());
                    log.info("[WS Explicit Topic Subscribed] Session '{}' subscribed to: '{}'", session.getId(), explicitTopic);
                }

                @SuppressWarnings("unchecked")
                List<String> explicitTopicsList = (List<String>) json.get("topics");
                if (explicitTopicsList != null) {
                    topics.addAll(explicitTopicsList);
                }

                // Send subscription confirmation envelope
                sendJson(session, Map.of(
                        "event", "SUBSCRIBED",
                        "status", "CONNECTED",
                        "userId", userId != null ? userId : "",
                        "coupleSpaceId", spaceId != null ? spaceId : "",
                        "subscribedTopics", new ArrayList<>(topics)
                ));
            } else if ("UNSUBSCRIBE_TOPIC".equalsIgnoreCase(action)) {
                String topicToUnsub = (String) json.get("topic");
                Set<String> topics = sessionTopicsMap.get(session.getId());
                if (topics != null && topicToUnsub != null) {
                    topics.remove(topicToUnsub.trim());
                }
            } else if ("PING".equalsIgnoreCase(action)) {
                sendJson(session, Map.of("event", "PONG", "timestamp", System.currentTimeMillis()));
            }
        } catch (Exception e) {
            log.error("[WS Handle Error] {}", e.getMessage(), e);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        String sid = session.getId();
        activeSessions.remove(sid);
        String userId = sessionUserMap.remove(sid);
        if (userId != null) {
            userSessionMap.remove(userId);
        }
        sessionSpaceMap.remove(sid);
        sessionTopicsMap.remove(sid);
        log.info("[WS Disconnected] Session ID: {}, User: {}", sid, userId);
    }

    /**
     * Broadcasts an event to an isolated dynamic couple topic:
     * e.g. /topic/couple.{coupleSpaceId}.{subTopic}
     * Delivers to local sessions and coordinates cross-server via Redis Pub/Sub if multi-instance is enabled.
     */
    public void broadcastToCoupleTopic(String coupleSpaceId, String subTopic, String eventType, Object payload) {
        if (coupleSpaceId == null || coupleSpaceId.isBlank()) return;

        String topic = "/topic/couple." + coupleSpaceId + "." + (subTopic != null ? subTopic : "*");
        Map<String, Object> envelope = Map.of(
                "event", eventType,
                "topic", topic,
                "coupleSpaceId", coupleSpaceId,
                "data", payload != null ? payload : Map.of(),
                "timestamp", System.currentTimeMillis()
        );

        // 1. Deliver to local subscribers on this node
        broadcastToLocalSubscribers(topic, envelope);

        // 2. Publish cross-server to Redis Pub/Sub cluster
        if (coupleEventPublisher != null) {
            coupleEventPublisher.publish(topic, envelope);
        }
    }

    /**
     * Broadcasts to all subscribers of a couple space (legacy + room wildcard).
     */
    public void broadcastToCoupleSpace(String coupleSpaceId, String eventType, Object payload) {
        broadcastToCoupleTopic(coupleSpaceId, "*", eventType, payload);
    }

    /**
     * Delivers an envelope to local connected sessions whose subscribed topics match the topic.
     * Invoked for local events as well as inbound events ingested from Redis Pub/Sub.
     */
    public void broadcastToLocalSubscribers(String topic, Map<String, Object> envelope) {
        if (topic == null || envelope == null) return;
        String coupleSpaceId = (String) envelope.get("coupleSpaceId");

        sessionTopicsMap.forEach((sid, subscribedTopics) -> {
            boolean matches = matchesTopic(topic, coupleSpaceId, sid, subscribedTopics);
            if (matches) {
                WebSocketSession session = activeSessions.get(sid);
                if (session != null && session.isOpen()) {
                    sendJson(session, envelope);
                }
            }
        });
    }

    private boolean matchesTopic(String publishTopic, String coupleSpaceId, String sid, Set<String> subscribedTopics) {
        // Direct match with coupleSpaceId mapping
        if (coupleSpaceId != null && coupleSpaceId.equals(sessionSpaceMap.get(sid))) {
            return true;
        }

        if (subscribedTopics == null || subscribedTopics.isEmpty()) {
            return false;
        }

        for (String pattern : subscribedTopics) {
            if (pattern.equals(publishTopic)) {
                return true;
            }
            if (pattern.endsWith(".*")) {
                String prefix = pattern.substring(0, pattern.length() - 1); // remove "*"
                if (publishTopic.startsWith(prefix)) {
                    return true;
                }
            }
            if (publishTopic.endsWith(".*")) {
                String prefix = publishTopic.substring(0, publishTopic.length() - 1);
                if (pattern.startsWith(prefix)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Directly sends an event to a specific user (e.g. partner)
     */
    public void sendToUser(String userId, String eventType, Object payload) {
        if (userId == null) return;
        String sid = userSessionMap.get(userId);
        if (sid != null) {
            WebSocketSession session = activeSessions.get(sid);
            if (session != null && session.isOpen()) {
                sendJson(session, Map.of(
                        "event", eventType,
                        "recipientId", userId,
                        "data", payload != null ? payload : Map.of(),
                        "timestamp", System.currentTimeMillis()
                ));
            }
        }
    }

    private synchronized void sendJson(WebSocketSession session, Map<String, Object> payload) {
        try {
            if (session.isOpen()) {
                String text = objectMapper.writeValueAsString(payload);
                session.sendMessage(new TextMessage(text));
            }
        } catch (IOException e) {
            log.warn("[WS Send Failure] Session: {}, Error: {}", session.getId(), e.getMessage());
        }
    }
}
