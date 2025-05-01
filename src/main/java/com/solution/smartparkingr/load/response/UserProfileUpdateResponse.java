package com.solution.smartparkingr.load.response;


public class UserProfileUpdateResponse {

    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean active;
    private String matricule; // Matricule for the vehicle, added here for completeness
    private String matriculeImageUrl; // URL for the vehicle's matricule image

    public UserProfileUpdateResponse(String firstName, String lastName, String email, String phone, boolean active, String matricule, String matriculeImageUrl) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.active = active;
        this.matricule = matricule;
        this.matriculeImageUrl = matriculeImageUrl;
    }

    // Getters
    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public boolean isActive() {
        return active;
    }

    public String getMatricule() {
        return matricule;
    }

    public String getMatriculeImageUrl() {
        return matriculeImageUrl;
    }
}