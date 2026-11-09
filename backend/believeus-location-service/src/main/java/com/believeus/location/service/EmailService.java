package com.believeus.location.service;

import com.believeus.location.entity.EmailOtpEntity;
import com.believeus.location.repository.EmailOtpRepository;
import jakarta.mail.internet.MimeMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;

@Service
@Slf4j
public class EmailService {

    private final EmailOtpRepository emailOtpRepository;
    private final JavaMailSender javaMailSender;

    @Value("${spring.mail.username:}")
    private String mailFrom;

    public EmailService(EmailOtpRepository emailOtpRepository,
                        @Autowired(required = false) JavaMailSender javaMailSender) {
        this.emailOtpRepository = emailOtpRepository;
        this.javaMailSender = javaMailSender;
    }

    @Transactional
    public String generateAndSendOtp(String email) {
        String normalizedEmail = email.trim().toLowerCase();

        // Generate 6-digit code between 100000 and 999999
        int codeInt = ThreadLocalRandom.current().nextInt(100000, 1000000);
        String otpCode = String.valueOf(codeInt);

        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(5);

        EmailOtpEntity otpEntity = EmailOtpEntity.builder()
                .email(normalizedEmail)
                .otpCode(otpCode)
                .expiresAt(expiresAt)
                .verified(false)
                .createdAt(LocalDateTime.now())
                .build();

        emailOtpRepository.save(otpEntity);

        // Send Email via Gmail SMTP
        sendEmail(normalizedEmail, otpCode);

        return otpCode;
    }

    private void sendEmail(String toEmail, String otpCode) {
        if (javaMailSender != null && mailFrom != null && !mailFrom.isBlank()) {
            try {
                MimeMessage message = javaMailSender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

                helper.setFrom(mailFrom, "Thae Thae");
                helper.setTo(toEmail);
                helper.setSubject("💌 Thae Thae — Your Private World Verification Code: " + otpCode);

                String htmlContent = """
                    <div style="font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; max-width: 520px; margin: 0 auto; padding: 28px; border: 1px solid #FFE4E6; border-radius: 20px; background: #FFF5F7;">
                      <div style="text-align: center; margin-bottom: 20px;">
                        <span style="font-size: 38px;">💖</span>
                        <h2 style="color: #BE185D; margin: 8px 0 4px 0; font-size: 24px; font-weight: 800;">Thae Thae</h2>
                        <p style="color: #64748B; margin: 0; font-size: 13px;">Your Private Couple World</p>
                      </div>
                      
                      <p style="color: #334155; font-size: 15px; line-height: 1.5; text-align: center;">
                        Here is your private 6-digit verification code to access your world with Thae Thae:
                      </p>
                      
                      <div style="background: #FFFFFF; border: 2px dashed #F43F5E; border-radius: 16px; padding: 18px; margin: 24px 0; text-align: center; box-shadow: 0 4px 12px rgba(244, 63, 94, 0.08);">
                        <span style="font-size: 36px; font-weight: 800; letter-spacing: 10px; color: #E11D48; font-family: monospace;">%s</span>
                      </div>
                      
                      <p style="color: #94A3B8; font-size: 12px; text-align: center; margin: 0 0 16px 0;">
                        ⏳ This code is valid for <strong>5 minutes</strong>. If you did not request this, you can safely ignore this email.
                      </p>
                      
                      <hr style="border: none; border-top: 1px solid #FECDD3; margin: 20px 0;" />
                      
                      <p style="color: #BE185D; font-size: 11px; text-align: center; margin: 0; font-weight: 600;">
                        Strict 1-to-1 privacy guaranteed • Thae Thae Couple World Engine
                      </p>
                    </div>
                """.formatted(otpCode);

                helper.setText(htmlContent, true);
                javaMailSender.send(message);

                log.info("Successfully dispatched Gmail SMTP OTP email to: {}", toEmail);
                return;
            } catch (Exception e) {
                log.warn("Failed to dispatch live SMTP email (falling back to dev log): {}", e.getMessage());
            }
        }

        // Development/Test fallback log
        log.info("==================================================================");
        log.info("[THAE THAE GMAIL EMAIL OTP] To: {}, Code: {} (Expires in 5 mins)", toEmail, otpCode);
        log.info("==================================================================");
    }
}
