package com.solution.smartparkingr.load.response;

public class UserProfileResponse {
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private boolean active;

    public UserProfileResponse(String firstName, String lastName, String email, String phone, boolean active) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.active = active;
    }

    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getEmail() { return email; }
    public String getPhone() { return phone; }
    public boolean isActive() { return active; }
}
