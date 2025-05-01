package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.User;

public interface UserService {

    User findById(Long userId);
    User findByEmail(String email);
    User save(User user);
    void delete(Long userId);
    boolean existsByEmail(String email);
    boolean existsByPhone(String phone);
}
