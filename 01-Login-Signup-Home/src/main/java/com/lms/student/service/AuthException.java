package com.lms.student.service;

/** Thrown when login fails (wrong password, inactive account, ...). */
public class AuthException extends Exception {
    public AuthException(String message) { super(message); }
}
