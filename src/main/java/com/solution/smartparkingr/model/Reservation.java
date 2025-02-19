package com.solution.smartparkingr.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservations")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;  // L'utilisateur qui a fait la réservation

    @Column(nullable = false)
    private String parkingLot;  // Nom ou ID du parking réservé

    @Column(nullable = false)
    private LocalDateTime startTime;  // Début de la réservation

    @Column(nullable = false)
    private LocalDateTime endTime;  // Fin de la réservation

    @Column(nullable = false)
    private String status;  // Ex: "CONFIRMED", "CANCELLED", "COMPLETED"

    public Reservation() {}

    public Reservation(User user, String parkingLot, LocalDateTime startTime, LocalDateTime endTime, String status) {
        this.user = user;
        this.parkingLot = parkingLot;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
    }

    // Getters et Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public String getParkingLot() { return parkingLot; }
    public void setParkingLot(String parkingLot) { this.parkingLot = parkingLot; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
