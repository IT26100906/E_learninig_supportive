package com.lms.student.model;

/** A premium student: same as Student (inheritance) but with a higher course limit (polymorphism). */
public class PremiumStudent extends Student {

    public static final int MAX_PREMIUM_COURSES = 15;

    public PremiumStudent(String id, String name, String email, String passwordHash) {
        super(id, name, email, passwordHash);
    }

    @Override public String getType() { return "PREMIUM"; }
    @Override public int getMaxEnrollments() { return MAX_PREMIUM_COURSES; }
    @Override public String getMembershipLabel() { return "Premium"; }
}
