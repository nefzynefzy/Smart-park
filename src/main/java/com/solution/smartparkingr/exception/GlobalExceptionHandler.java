package com.solution.smartparkingr.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler extends ResponseEntityExceptionHandler {

    // Handle ResourceNotFoundException
    @ExceptionHandler(ResourceNotFound.class)
    public ResponseEntity<?> handleResourceNotFound(ResourceNotFound ex) {
        return ResponseEntity.status(404).body(ex.getMessage());
    }

    // Handle other exceptions
    @ExceptionHandler(Exception.class)
    public ResponseEntity<?> handleGenericException(Exception ex) {
        return ResponseEntity.status(500).body("An unexpected error occurred: " + ex.getMessage());
    }
}
