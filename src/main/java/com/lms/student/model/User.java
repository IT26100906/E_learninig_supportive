package com.lms.student.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Base class for every account in the LMS.
 *
 * OOP concepts shown here:
 *  - ABSTRACTION    : User is abstract; subclasses must define role-specific behaviour.
 *  - ENCAPSULATION  : all fields are private, accessed only through getters/setters.
 *  - INHERITANCE    : Student, PremiumStudent and Admin extend this class.
 *  - POLYMORPHISM   : getRole(), getType(), canManageUsers(), getHomePath() and
 *                     getMaxEnrollments() are overridden by each subclass.
 */
public abstract class User {

    private String id;
    private String name;
    private String email;
    private String passwordHash;
    private String phone;
    private LocalDate dateOfBirth;
    private String address;
    private AccountStatus status = AccountStatus.ACTIVE;
    private LocalDate registeredDate = LocalDate.now();
    private LocalDateTime lastLogin;
    private String profilePicture;     // file name stored in data/profile-pics
    private String securityQuestion;
    private String securityAnswerHash;
    private StudentLevel level = StudentLevel.UNDERGRAD;  // Child / School / A/L / Undergraduate
    private String levelDetail = "";                      // age, grade, stream or degree

    protected User(String id, String name, String email, String passwordHash) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    // ---------- Polymorphic behaviour (each subclass overrides) ----------

    /** Short role name used for authorization, e.g. STUDENT / ADMIN. */
    public abstract String getRole();

    /** Account type written in the first column of users.txt. */
    public abstract String getType();

    /** Can this user manage other users (admin features)? */
    public abstract boolean canManageUsers();

    /** URL of the page shown right after login. */
    public abstract String getHomePath();

    /** Maximum number of courses this user may enrol in (used by the Enrollment module). */
    public abstract int getMaxEnrollments();

    // ---------- Common behaviour ----------

    public boolean isActive() {
        return status == AccountStatus.ACTIVE;
    }

    /** Converts this object to one line of users.txt (fields separated by '|'). */
    public String toFileLine() {
        return String.join("|",
            nz(getType()), nz(id), nz(name), nz(email), nz(passwordHash), nz(phone),
            dateOfBirth == null ? "" : dateOfBirth.toString(),
            nz(address), status.name(),
            registeredDate == null ? "" : registeredDate.toString(),
            lastLogin == null ? "" : lastLogin.toString(),
            nz(profilePicture), nz(securityQuestion), nz(securityAnswerHash),
            level.name(), nz(levelDetail));
    }

    private static String nz(String s) {
        return s == null ? "" : s;
    }

    @Override
    public String toString() {
        return getType() + "[" + id + ", " + name + ", " + email + "]";
    }

    // ---------- Getters & setters (encapsulation) ----------

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public AccountStatus getStatus() { return status; }
    public void setStatus(AccountStatus status) { this.status = status; }

    public LocalDate getRegisteredDate() { return registeredDate; }
    public void setRegisteredDate(LocalDate registeredDate) { this.registeredDate = registeredDate; }

    public LocalDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(LocalDateTime lastLogin) { this.lastLogin = lastLogin; }

    public String getProfilePicture() { return profilePicture; }
    public void setProfilePicture(String profilePicture) { this.profilePicture = profilePicture; }

    public String getSecurityQuestion() { return securityQuestion; }
    public void setSecurityQuestion(String securityQuestion) { this.securityQuestion = securityQuestion; }

    public String getSecurityAnswerHash() { return securityAnswerHash; }
    public void setSecurityAnswerHash(String securityAnswerHash) { this.securityAnswerHash = securityAnswerHash; }

    /** Initial letter(s) for the avatar when no profile picture is uploaded. */
    public String getInitials() {
        if (name == null || name.isBlank()) return "?";
        String[] parts = name.trim().split("\\s+");
        String first = parts[0].substring(0, 1);
        String last = parts.length > 1 ? parts[parts.length - 1].substring(0, 1) : "";
        return (first + last).toUpperCase();
    }

    public StudentLevel getLevel() { return level; }
    public void setLevel(StudentLevel level) { this.level = level == null ? StudentLevel.UNDERGRAD : level; }

    public String getLevelDetail() { return levelDetail; }
    public void setLevelDetail(String levelDetail) { this.levelDetail = levelDetail == null ? "" : levelDetail; }

    /** Text like "Grade 8", "Age 5", "A/L - Commerce" or the degree name. */
    public String getLevelDisplay() { return level.describe(levelDetail); }

    // ---------- Display helpers used by the JSP pages ----------

    public String getLastLoginText() {
        return lastLogin == null ? "Never"
            : lastLogin.format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
    }

    /** yyyy-MM-dd text (empty if not set) - used as the value of date inputs. */
    public String getDateOfBirthText() {
        return dateOfBirth == null ? "" : dateOfBirth.toString();
    }

    /** How much of the profile is filled in (0-100). */
    public int getProfileCompleteness() {
        int total = 6, filled = 2; // name + email are always present
        if (phone != null && !phone.isBlank()) filled++;
        if (dateOfBirth != null) filled++;
        if (address != null && !address.isBlank()) filled++;
        if (profilePicture != null && !profilePicture.isBlank()) filled++;
        return filled * 100 / total;
    }
}
