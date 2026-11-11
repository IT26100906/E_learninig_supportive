package com.lms.student.model;

/** A regular (free) student account. Inherits everything from User. */
public class Student extends User {

    public static final int MAX_COURSES = 5;

    public Student(String id, String name, String email, String passwordHash) {
        super(id, name, email, passwordHash);
    }

    @Override public String getRole() { return "STUDENT"; }
    @Override public String getType() { return "STUDENT"; }
    @Override public boolean canManageUsers() { return false; }
    @Override public String getHomePath() { return "/dashboard"; }
    @Override public int getMaxEnrollments() { return MAX_COURSES; }

    /** Text shown on the profile page; overridden by PremiumStudent. */
    public String getMembershipLabel() { return "Regular"; }
}
