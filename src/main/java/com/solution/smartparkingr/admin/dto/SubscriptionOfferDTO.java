package com.solution.smartparkingr.admin.dto;

import lombok.Data;

@Data
public class SubscriptionOfferDTO {
    private Long id;
    private String name; // "Basique", "Premium", "Entreprise"
    private double price;
    private int duration;
    private boolean isActive;
    private int subscribers;
}