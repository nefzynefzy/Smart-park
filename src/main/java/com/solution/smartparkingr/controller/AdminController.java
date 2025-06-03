package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.admin.dto.*;
import com.solution.smartparkingr.admin.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:4200")
public class AdminController {
    private final AdminService adminService;

    @GetMapping("/analytics")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.AnalyticsDataDTO> getAnalyticsData() {
        return ResponseEntity.ok(adminService.getAnalyticsData());
    }

    @GetMapping("/charts")
    public ResponseEntity<Map<String, Object>> getChartData(@RequestParam String period) {
        return ResponseEntity.ok(adminService.getChartData(period));
    }

    @GetMapping("/notifications")
    public ResponseEntity<List<Map<String, String>>> getNotifications() {
        return ResponseEntity.ok(adminService.getNotifications());
    }

    @GetMapping("/users")
    public ResponseEntity<List<UserDTO>> getUsers() {
        return ResponseEntity.ok(adminService.getUsers());
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.UserDTO> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getUserById(id));
    }

    @PostMapping("/users")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.UserDTO> createUser(@RequestBody UserDTO userDTO) {
        return ResponseEntity.ok(adminService.createUser(userDTO));
    }

    @PutMapping("/users/{id}")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.UserDTO> updateUser(@PathVariable Long id, @RequestBody com.solution.smartparkingr.admin.dto.UserDTO userDTO) {
        return ResponseEntity.ok(adminService.updateUser(id, userDTO));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        adminService.deleteUser(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/users/{userId}/reservations")
    public ResponseEntity<List<ReservationDTO>> getUserReservations(@PathVariable Long userId) {
        return ResponseEntity.ok(adminService.getUserReservations(userId));
    }

    @GetMapping("/parking-settings")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.ParkingSettingsDTO> getParkingSettings() {
        return ResponseEntity.ok(adminService.getParkingSettings());
    }

    @PostMapping("/parking-settings")
    public ResponseEntity<com.solution.smartparkingr.admin.dto.ParkingSettingsDTO> saveParkingSettings(@RequestBody ParkingSettingsDTO settingsDTO) {
        return ResponseEntity.ok(adminService.saveParkingSettings(settingsDTO));
    }

    @GetMapping("/parking-settings/history")
    public ResponseEntity<List<Map<String, Object>>> getSettingsHistory() {
        return ResponseEntity.ok(adminService.getSettingsHistory());
    }

    @GetMapping("/parking-settings/export")
    public ResponseEntity<byte[]> exportSettings() throws Exception {
        String json = adminService.exportSettings();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=parking-settings.json")
                .contentType(MediaType.APPLICATION_JSON)
                .body(json.getBytes());
    }

    @GetMapping("/estimate-revenue")
    public ResponseEntity<RevenueEstimateDTO> estimateRevenue() {
        return ResponseEntity.ok(adminService.estimateRevenue());
    }
}