package com.solution.smartparkingr.config;

import com.solution.smartparkingr.model.ParkingSpot;
import com.solution.smartparkingr.repository.ParkingSpotRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner initParkingSpots(ParkingSpotRepository repository) {
        return args -> {
            // Check if the spot "P1" exists to avoid duplicating data
            if (!repository.existsByName("P1")) {
                for (int i = 1; i <= 50; i++) {
                    ParkingSpot spot = new ParkingSpot();
                    spot.setName("P" + i);
                    spot.setType("standard");
                    spot.setPrice(5.0);
                    spot.setAvailable(true);
                    repository.save(spot);
                }
                System.out.println("✅ 50 parking spots initialized!");
            } else {
                System.out.println("🚗 Parking spots already exist!");
            }
        };
    }
}