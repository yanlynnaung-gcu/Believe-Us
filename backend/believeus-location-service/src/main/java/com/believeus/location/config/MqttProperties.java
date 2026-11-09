package com.believeus.location.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "believeus.mqtt")
public class MqttProperties {

    private boolean enabled = true;
    private String brokerUrl = "tcp://localhost:1883";
    private String clientId = "believeus-backend-sos";
    private boolean cleanSession = false;
    private int keepAliveSeconds = 30;
    private int qos = 1;
    private Embedded embedded = new Embedded();

    @Data
    public static class Embedded {
        private boolean enabled = true;
        private int port = 1883;
        private String host = "0.0.0.0";
    }
}
