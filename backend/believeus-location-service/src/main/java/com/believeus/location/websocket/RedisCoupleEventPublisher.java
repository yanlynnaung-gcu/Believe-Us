package com.believeus.location.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@ConditionalOnProperty(name = "believeus.redis.pubsub.enabled", havingValue = "true")
@RequiredArgsConstructor
@Slf4j
public class RedisCoupleEventPublisher implements CoupleEventPublisher {

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    @Value("${believeus.redis.pubsub.channel:believeus.couple.events}")
    private String channel;

    @Override
    public void publish(String topic, Map<String, Object> envelope) {
        try {
            String messageJson = objectMapper.writeValueAsString(envelope);
            redisTemplate.convertAndSend(channel, messageJson);
            log.debug("[Redis PubSub Dispatched] Topic: {}, Channel: {}", topic, channel);
        } catch (Exception e) {
            log.error("[Redis PubSub Dispatch Failed] Topic: {}, Error: {}", topic, e.getMessage());
        }
    }
}
