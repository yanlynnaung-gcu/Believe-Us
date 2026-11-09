package com.believeus.location.websocket;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.listener.ChannelTopic;
import org.springframework.data.redis.listener.RedisMessageListenerContainer;
import org.springframework.data.redis.listener.adapter.MessageListenerAdapter;

@Configuration
@ConditionalOnProperty(name = "believeus.redis.pubsub.enabled", havingValue = "true")
@Slf4j
public class RedisPubSubConfig {

    @Value("${believeus.redis.pubsub.channel:believeus.couple.events}")
    private String channel;

    @Bean
    public ChannelTopic coupleEventsTopic() {
        return new ChannelTopic(channel);
    }

    @Bean
    public MessageListenerAdapter listenerAdapter(RedisCoupleEventListener listener) {
        return new MessageListenerAdapter(listener);
    }

    @Bean
    public RedisMessageListenerContainer redisMessageListenerContainer(
            RedisConnectionFactory connectionFactory,
            MessageListenerAdapter listenerAdapter,
            ChannelTopic coupleEventsTopic) {
        RedisMessageListenerContainer container = new RedisMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        container.addMessageListener(listenerAdapter, coupleEventsTopic);
        log.info("[Redis PubSub Enabled] Subscribed to multi-instance cluster channel: '{}'", channel);
        return container;
    }
}
