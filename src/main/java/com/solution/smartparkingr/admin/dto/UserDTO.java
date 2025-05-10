package com.solution.smartparkingr.admin.dto;

import lombok.Data;

@Data
public class UserDTO {
    private long id;
    private String name; // Concaténation de firstName et lastName (pour affichage)
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String password; // Ajout pour le formulaire
    private String role; // Simplifié depuis Set<Role> pour l'admin
    private boolean active; // Ajout pour activer/désactiver l'utilisateur
    private CoordinatesDTO coordinates;
}