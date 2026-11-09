package com.believeus.location.mqtt;

import com.believeus.location.config.MqttProperties;
import io.moquette.BrokerConstants;
import io.moquette.broker.Server;
import io.moquette.broker.config.IConfig;
import io.moquette.broker.config.MemoryConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.SmartLifecycle;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.IOException;
import java.util.Properties;

@Component
@RequiredArgsConstructor
@Slf4j
public class EmbeddedMqttBroker implements SmartLifecycle {

    private final MqttProperties mqttProperties;
    private Server server;
    private boolean running = false;

    @Override
    public void start() {
        if (!mqttProperties.isEnabled() || !mqttProperties.getEmbedded().isEnabled()) {
            log.info("[MQTT Broker] Embedded broker disabled by configuration.");
            return;
        }

        try {
            int port = mqttProperties.getEmbedded().getPort();
            String host = mqttProperties.getEmbedded().getHost();

            Properties properties = new Properties();
            properties.setProperty(BrokerConstants.PORT_PROPERTY_NAME, String.valueOf(port));
            properties.setProperty(BrokerConstants.HOST_PROPERTY_NAME, host);
            properties.setProperty(BrokerConstants.ALLOW_ANONYMOUS_PROPERTY_NAME, "true");
            properties.setProperty(BrokerConstants.ENABLE_TELEMETRY_NAME, "false");
            properties.setProperty(BrokerConstants.IMMEDIATE_BUFFER_FLUSH_PROPERTY_NAME, "true");

            File dataDir = new File("./data/moquette");
            if (!dataDir.exists()) {
                dataDir.mkdirs();
            }
            properties.setProperty(BrokerConstants.PERSISTENT_STORE_PROPERTY_NAME, "./data/moquette/moquette_store.mapdb");

            IConfig config = new MemoryConfig(properties);
            server = new Server();
            server.startServer(config);
            running = true;
            log.info("[MQTT Broker] Embedded Moquette MQTT Broker started successfully on {}:{}", host, port);
        } catch (Throwable t) {
            log.warn("[MQTT Broker] Could not start embedded broker (likely external broker already running on port): {}", t.getMessage());
            running = false;
        }
    }

    @Override
    public void stop() {
        if (server != null && running) {
            try {
                server.stopServer();
                log.info("[MQTT Broker] Embedded Moquette MQTT Broker stopped.");
            } catch (Exception e) {
                log.warn("[MQTT Broker] Error stopping embedded broker: {}", e.getMessage());
            } finally {
                running = false;
                server = null;
            }
        }
    }

    @Override
    public boolean isRunning() {
        return running;
    }

    @Override
    public int getPhase() {
        // High priority startup before clients try to connect
        return Integer.MIN_VALUE + 100;
    }
}
