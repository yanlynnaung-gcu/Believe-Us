package com.believeus.location.websocket;

import java.util.Map;

public interface CoupleEventPublisher {
    void publish(String topic, Map<String, Object> envelope);
}
