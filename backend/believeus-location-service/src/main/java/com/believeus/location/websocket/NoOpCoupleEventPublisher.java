package com.believeus.location.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@ConditionalOnProperty(name = "believeus.redis.pubsub.enabled", havingValue = "false", matchIfMissing = true)
@Slf4j
public class NoOpCoupleEventPublisher implements CoupleEventPublisher {

    public NoOpCoupleEventPublisher() {
        log.info("[PubSub] Running with Local In-Memory Event Routing (Single-Node Mode).");
    }

    @Override
    public void publish(String topic, Map<String, Object> envelope) {
        // No-op for single node: local WebSocket handler already delivers to connected sessions
    }
}
