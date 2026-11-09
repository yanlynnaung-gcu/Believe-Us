package com.believeus.location.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.File;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    @Override
    public void run(String... args) {
        log.info("==================================================================");
        log.info("BelieveUs Sanctuary Engine: Initialized with Persistent Database.");
        log.info("Database is clean. Ready for real Boyfriend & Girlfriend registration.");
        log.info("==================================================================");

        // Ensure upload directories exist
        File avatarsDir = new File("./uploads/avatars");
        if (!avatarsDir.exists()) {
            avatarsDir.mkdirs();
        }
        File coversDir = new File("./uploads/covers");
        if (!coversDir.exists()) {
            coversDir.mkdirs();
        }
    }
}
