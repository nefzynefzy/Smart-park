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
            // Vérifie si la place "P1" existe déjà avant de créer les 50 places
            if (!repository.existsByCode("P1")) {
                for (int i = 1; i <= 50; i++) {
                    ParkingSpot spot = new ParkingSpot();
                    spot.setCode("P" + i);
                    spot.setAvailable(true);
                    repository.save(spot);
                }
                System.out.println("✅ 50 places de parking initialisées !");
            } else {
                System.out.println("🚗 Les places de parking existent déjà !");
            }
        };
    }
}
