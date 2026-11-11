package com.lms.student.service;

import java.util.List;

/** Thrown when user input is invalid. Carries every error message to show on the page. */
public class ValidationException extends Exception {
    private final List<String> errors;

    public ValidationException(List<String> errors) {
        super(String.join("; ", errors));
        this.errors = errors;
    }

    public ValidationException(String error) {
        this(List.of(error));
    }

    public List<String> getErrors() { return errors; }
}
