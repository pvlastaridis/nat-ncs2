package uth.bio.phosphpred.config;

import org.springframework.boot.actuate.audit.AuditEvent;
import org.springframework.boot.actuate.audit.listener.AuditApplicationEvent;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.ApplicationEventPublisherAware;
import org.springframework.context.annotation.Configuration;

/**
 * Created by panos on 1/8/2017.
 */
@Configuration
public class AuditEventPublisher implements ApplicationEventPublisherAware {
    private ApplicationEventPublisher publisher;

    @Override
    public void setApplicationEventPublisher(
        ApplicationEventPublisher publisher) {
        this.publisher = publisher;
    }

    public void publish(AuditEvent event) {
        if (this.publisher != null)
            this.publisher.publishEvent(new AuditApplicationEvent(event));
    }
}
