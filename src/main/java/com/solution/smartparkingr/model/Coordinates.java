package com.solution.smartparkingr.model;

import jakarta.persistence.Embeddable;
import lombok.Data;

@Embeddable
@Data
public class Coordinates {
    private double latitude;
    private double longitude;
}