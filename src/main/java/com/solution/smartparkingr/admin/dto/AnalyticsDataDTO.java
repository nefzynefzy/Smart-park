package com.solution.smartparkingr.admin.dto;

import lombok.Data;

import java.util.List;

@Data
public class AnalyticsDataDTO {
    private int totalReservations;
    private double totalRevenue;
    private int activeUsers;
    private double occupancyRate;
    private int totalVehicles; // Ajout
    private double dailyRevenue; // Ajout
    private double averageParkingTime; // Ajout (en heures)
    private List<ChartDataDTO> reservationsByDay;
}