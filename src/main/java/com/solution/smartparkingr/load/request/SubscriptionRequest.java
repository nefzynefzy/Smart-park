package com.solution.smartparkingr.load.request;

public class SubscriptionRequest {
    private Long userId;
    private String type;

    // Constructors
    public SubscriptionRequest() {}

    public SubscriptionRequest(Long userId, String type) {
        this.userId = userId;
        this.type = type;
    }

    // Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
