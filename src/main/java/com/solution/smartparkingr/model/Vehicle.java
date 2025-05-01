package com.solution.smartparkingr.model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "vehicles")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 🚹 Owner of the vehicle
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // 🆔 License plate (matricule)
    @Column(nullable = false, unique = true)
    private String matricule;

    // 📸 Placeholder for license plate image (future file upload)
    @Column(name = "matricule_image_url", nullable = true)
    private String matriculeImageUrl;

    // 🅿️ Link to reservations
    @OneToMany(mappedBy = "vehicle")
    private List<Reservation> reservations;

    // 👇 Optional: add vehicle type or brand later
    // private String brand;
    // private String color;

    public Vehicle() {}

    public Vehicle(User user, String matricule, String matriculeImageUrl) {
        this.user = user;
        this.matricule = matricule;
        this.matriculeImageUrl = matriculeImageUrl;
    }

    // === Getters & Setters ===

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public String getMatriculeImageUrl() {
        return matriculeImageUrl;
    }

    public void setMatriculeImageUrl(String matriculeImageUrl) {
        this.matriculeImageUrl = matriculeImageUrl;
    }

    public List<Reservation> getReservations() {
        return reservations;
    }

    public void setReservations(List<Reservation> reservations) {
        this.reservations = reservations;
    }
}
