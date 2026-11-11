package com.lms.student.model;

/** Administrator account. Can manage all students. */
public class Admin extends User {

    public Admin(String id, String name, String email, String passwordHash) {
        super(id, name, email, passwordHash);
    }

    @Override public String getRole() { return "ADMIN"; }
    @Override public String getType() { return "ADMIN"; }
    @Override public boolean canManageUsers() { return true; }
    @Override public String getHomePath() { return "/admin/dashboard"; }
    @Override public int getMaxEnrollments() { return 0; }
}
