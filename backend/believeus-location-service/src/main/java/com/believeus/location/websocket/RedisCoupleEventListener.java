package com.believeus.location.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.data.redis.connection.Message;
import org.springframework.data.redis.connection.MessageListener;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Map;

@Component
@Slf4j
public class RedisCoupleEventListener implements MessageListener {

    private final ObjectMapper objectMapper;
    private final SyncWebSocketHandler syncWebSocketHandler;

    public RedisCoupleEventListener(ObjectMapper objectMapper, @Lazy SyncWebSocketHandler syncWebSocketHandler) {
        this.objectMapper = objectMapper;
        this.syncWebSocketHandler = syncWebSocketHandler;
    }

    @Override
    public void onMessage(Message message, byte[] pattern) {
        try {
            String jsonStr = new String(message.getBody(), StandardCharsets.UTF_8);
            @SuppressWarnings("unchecked")
            Map<String, Object> envelope = objectMapper.readValue(jsonStr, Map.class);
            String topic = (String) envelope.get("topic");

            log.debug("[Redis PubSub Received] Cross-Server Event on topic: {}", topic);
            syncWebSocketHandler.broadcastToLocalSubscribers(topic, envelope);
        } catch (Exception e) {
            log.error("[Redis PubSub Ingestion Error] {}", e.getMessage(), e);
        }
    }
}
