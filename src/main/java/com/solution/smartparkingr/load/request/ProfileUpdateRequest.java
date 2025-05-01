package com.solution.smartparkingr.load.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ProfileUpdateRequest {

    @NotBlank
    private String firstName;

    @NotBlank
    private String lastName;

    @Email
    @NotBlank
    private String email;

    @NotBlank
    private String phone;

    @Size(min = 6)
    private String oldPassword;

    @Size(min = 6)
    private String password;

    private String matricule;

    private String matriculeImageUrl;  // Change byte array to store the image URL

    // Constructor
    public ProfileUpdateRequest(String firstName, String lastName, String email, String phone,
                                String oldPassword, String password, String matricule, String matriculeImageUrl) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.oldPassword = oldPassword;
        this.password = password;
        this.matricule = matricule;
        this.matriculeImageUrl = matriculeImageUrl;
    }

    // Getters and Setters
    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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
}
