package com.lms.student.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Factory that creates the right subclass (Student / PremiumStudent / Admin)
 * from a type name or from one line of users.txt.
 */
public final class UserFactory {

    private UserFactory() { }

    public static User create(String type, String id, String name, String email, String passwordHash) {
        String t = type == null ? "STUDENT" : type.trim().toUpperCase();
        switch (t) {
            case "ADMIN":   return new Admin(id, name, email, passwordHash);
            case "PREMIUM": return new PremiumStudent(id, name, email, passwordHash);
            default:        return new Student(id, name, email, passwordHash);
        }
    }

    /** Minimum number of '|' separated columns in one users.txt line (new files have 16). */
    public static final int COLUMNS = 14;

    /** Parses one line of users.txt. Returns null if the line is invalid. */
    public static User fromFileLine(String line) {
        if (line == null || line.isBlank() || line.startsWith("#")) return null;
        String[] p = line.split("\\|", -1);
        if (p.length < COLUMNS) return null;
        try {
            User u = create(p[0], p[1], p[2], p[3], p[4]);
            u.setPhone(p[5]);
            u.setDateOfBirth(p[6].isEmpty() ? null : LocalDate.parse(p[6]));
            u.setAddress(p[7]);
            u.setStatus(AccountStatus.fromString(p[8]));
            u.setRegisteredDate(p[9].isEmpty() ? LocalDate.now() : LocalDate.parse(p[9]));
            u.setLastLogin(p[10].isEmpty() ? null : LocalDateTime.parse(p[10]));
            u.setProfilePicture(p[11]);
            u.setSecurityQuestion(p[12]);
            u.setSecurityAnswerHash(p[13]);
            if (p.length >= 16) {            // older files have only 14 columns
                u.setLevel(StudentLevel.fromString(p[14]));
                u.setLevelDetail(p[15]);
            }
            return u;
        } catch (RuntimeException e) {
            System.err.println("Skipping invalid line in users.txt: " + line);
            return null;
        }
    }
}
