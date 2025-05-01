package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.model.ParkingSpot;
import com.solution.smartparkingr.service.ParkingSpotService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/parking-spots")
@RequiredArgsConstructor
public class ParkingSpotController {

    private final ParkingSpotService service;

    @GetMapping
    public List<ParkingSpot> getAll() {
        return service.getAllSpots();
    }

    @GetMapping("/available")
    public List<ParkingSpot> getAvailable() {
        return service.getAvailableSpots();
    }

    @PostMapping("/release/{id}")
    public void releaseSpot(@PathVariable Long id) {
        service.releaseSpot(id);
    }
}
