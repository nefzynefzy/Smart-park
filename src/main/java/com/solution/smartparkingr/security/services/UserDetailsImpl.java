package com.solution.smartparkingr.security.services;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.solution.smartparkingr.model.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

public class UserDetailsImpl implements UserDetails {

    private long id;
    private String username;  // Use this field for email (username = email)
    private String email;     // Store email separately from username
    private String firstName; // Added first name
    private String lastName;  // Added last name
    private String phone;     // Added phone number

    @JsonIgnore
    private String password;

    private Collection<? extends GrantedAuthority> authorities;

    // Constructor
    public UserDetailsImpl(long id, String username, String email, String password,
                           String firstName, String lastName, String phone,
                           Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;  // Store email here as the username
        this.email = email;        // Store email separately
        this.password = password;
        this.firstName = firstName;  // Set first name
        this.lastName = lastName;    // Set last name
        this.phone = phone;          // Set phone
        this.authorities = authorities;
    }

    // Static build method to construct UserDetailsImpl from User
    public static UserDetailsImpl build(User user) {
        // Map roles to granted authorities
        List<GrantedAuthority> authorities = user.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority(role.getName().name())) // Assuming Role has 'name'
                .collect(Collectors.toList());

        return new UserDetailsImpl(
                user.getId(),
                user.getEmail(),  // Use email as the username
                user.getEmail(),  // Store email separately
                user.getPassword(),
                user.getFirstName(),  // Use first name from User
                user.getLastName(),   // Use last name from User
                user.getPhone(),      // Use phone from User
                authorities
        );
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username; // Return email here as 'username'
    }

    public String getEmail() {
        return email;  // You can use this to get the user's email
    }

    public String getFirstName() {
        return firstName; // Added getter for firstName
    }

    public String getLastName() {
        return lastName;  // Added getter for lastName
    }

    public String getPhone() {
        return phone;     // Added getter for phone
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    // Getter for id
    public long getId() {
        return id;
    }
}
