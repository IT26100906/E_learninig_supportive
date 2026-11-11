package com.lms.student.model;

/** Status of a user account. INACTIVE accounts cannot log in. */
public enum AccountStatus {
    ACTIVE, INACTIVE;

    public static AccountStatus fromString(String s) {
        try {
            return AccountStatus.valueOf(s == null ? "" : s.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return ACTIVE;
        }
    }
}
