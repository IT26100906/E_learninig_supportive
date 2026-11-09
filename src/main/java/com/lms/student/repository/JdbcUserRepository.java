package com.lms.student.repository;

import com.lms.student.model.AccountStatus;
import com.lms.student.model.StudentLevel;
import com.lms.student.model.User;
import com.lms.student.model.UserFactory;
import com.lms.student.util.AppConfig;
import com.lms.student.util.DbConfig;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Stores users in a SQL database (H2 file database by default, or MySQL) - table "users".
 * Implements the same UserRepository interface as the old text-file version, so the
 * service, servlets and JSP pages did not need to change.
 *
 * All SQL uses PreparedStatement (parameters are never pasted into the query text),
 * which also protects the app against SQL injection.
 */
public class JdbcUserRepository implements UserRepository {

    private static final JdbcUserRepository INSTANCE = new JdbcUserRepository();

    public static JdbcUserRepository getInstance() { return INSTANCE; }

    private static final String COLUMNS =
        "user_type, id, name, email, password_hash, phone, date_of_birth, address, status, " +
        "registered_date, last_login, profile_picture, security_question, security_answer_hash, " +
        "student_level, level_detail";

    private volatile boolean ready = false;

    private JdbcUserRepository() { }

    // ------------------------------------------------------------------ setup

    /** Creates the table if needed and imports an old data/users.txt once. Called at start-up. */
    public synchronized void init() {
        if (ready) return;
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement()) {
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                " id                   VARCHAR(12)  NOT NULL PRIMARY KEY," +
                " user_type            VARCHAR(10)  NOT NULL," +
                " name                 VARCHAR(100) NOT NULL," +
                " email                VARCHAR(100) NOT NULL," +
                " password_hash        VARCHAR(255) NOT NULL," +
                " phone                VARCHAR(20)," +
                " date_of_birth        DATE," +
                " address              VARCHAR(255)," +
                " status               VARCHAR(10)  NOT NULL," +
                " registered_date      DATE         NOT NULL," +
                " last_login           DATETIME," +
                " profile_picture      VARCHAR(255)," +
                " security_question    VARCHAR(255)," +
                " security_answer_hash VARCHAR(255)," +
                " student_level        VARCHAR(12)  NOT NULL," +
                " level_detail         VARCHAR(100)," +
                " CONSTRAINT uq_users_email UNIQUE (email))");
            ready = true;
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot connect to the database (" + DbConfig.describe() + "): " + e.getMessage(), e);
        }
        importOldTextFile();
    }

    /** If the table is empty and the old data/users.txt exists, copy its users into the database. */
    private void importOldTextFile() {
        File old = AppConfig.usersFile();
        if (!old.exists() || !findAll().isEmpty()) return;
        List<User> users = FileUserRepository.getInstance().findAll();
        if (users.isEmpty()) return;
        for (User u : users) create(u);
        try {
            Files.move(old.toPath(), new File(old.getParentFile(), "users.txt.imported").toPath(),
                       StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ignored) { /* the import itself worked */ }
        System.out.println("Imported " + users.size() + " user(s) from users.txt into the database.");
    }

    // ------------------------------------------------------------------ READ

    @Override
    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("SELECT " + COLUMNS + " FROM users ORDER BY id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { throw fail("read users", e); }
        return list;
    }

    @Override
    public Optional<User> findById(String id) {
        if (id == null) return Optional.empty();
        return one("SELECT " + COLUMNS + " FROM users WHERE LOWER(id) = LOWER(?)", id.trim());
    }

    @Override
    public Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        return one("SELECT " + COLUMNS + " FROM users WHERE LOWER(email) = LOWER(?)", email.trim());
    }

    private Optional<User> one(String sql, String param) {
        try (Connection c = DbConfig.connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, param);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? Optional.of(map(rs)) : Optional.empty();
            }
        } catch (SQLException e) { throw fail("read a user", e); }
    }

    // ------------------------------------------------------------------ CREATE

    @Override
    public void create(User u) {
        String sql = "INSERT INTO users (" + COLUMNS + ") VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection c = DbConfig.connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, u.getType());
            ps.setString(i++, u.getId());
            ps.setString(i++, u.getName());
            ps.setString(i++, u.getEmail());
            ps.setString(i++, u.getPasswordHash());
            bind(ps, i, u);
            ps.executeUpdate();
        } catch (SQLException e) { throw fail("save the new user", e); }
    }

    // ------------------------------------------------------------------ UPDATE

    @Override
    public void update(User u) {
        String sql = "UPDATE users SET user_type=?, name=?, email=?, password_hash=?, phone=?, date_of_birth=?, " +
                     "address=?, status=?, registered_date=?, last_login=?, profile_picture=?, security_question=?, " +
                     "security_answer_hash=?, student_level=?, level_detail=? WHERE LOWER(id) = LOWER(?)";
        try (Connection c = DbConfig.connect(); PreparedStatement ps = c.prepareStatement(sql)) {
            int i = 1;
            ps.setString(i++, u.getType());
            ps.setString(i++, u.getName());
            ps.setString(i++, u.getEmail());
            ps.setString(i++, u.getPasswordHash());
            i = bind(ps, i, u);
            ps.setString(i, u.getId());
            ps.executeUpdate();
        } catch (SQLException e) { throw fail("update the user", e); }
    }

    // ------------------------------------------------------------------ DELETE

    @Override
    public boolean delete(String id) {
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("DELETE FROM users WHERE LOWER(id) = LOWER(?)")) {
            ps.setString(1, id == null ? "" : id.trim());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { throw fail("delete the user", e); }
    }

    // ------------------------------------------------------------------ helpers

    /** Binds phone ... level_detail (the 11 columns shared by INSERT and UPDATE) and returns the next index. */
    private int bind(PreparedStatement ps, int i, User u) throws SQLException {
        ps.setString(i++, u.getPhone());
        if (u.getDateOfBirth() == null) ps.setNull(i++, Types.DATE); else ps.setDate(i++, Date.valueOf(u.getDateOfBirth()));
        ps.setString(i++, u.getAddress());
        ps.setString(i++, u.getStatus().name());
        ps.setDate(i++, Date.valueOf(u.getRegisteredDate() == null ? LocalDate.now() : u.getRegisteredDate()));
        if (u.getLastLogin() == null) ps.setNull(i++, Types.TIMESTAMP); else ps.setTimestamp(i++, Timestamp.valueOf(u.getLastLogin()));
        ps.setString(i++, u.getProfilePicture());
        ps.setString(i++, u.getSecurityQuestion());
        ps.setString(i++, u.getSecurityAnswerHash());
        ps.setString(i++, u.getLevel().name());
        ps.setString(i++, u.getLevelDetail());
        return i;
    }

    private User map(ResultSet rs) throws SQLException {
        User u = UserFactory.create(rs.getString("user_type"), rs.getString("id"), rs.getString("name"),
                                    rs.getString("email"), rs.getString("password_hash"));
        u.setPhone(nz(rs.getString("phone")));
        Date dob = rs.getDate("date_of_birth");
        u.setDateOfBirth(dob == null ? null : dob.toLocalDate());
        u.setAddress(nz(rs.getString("address")));
        u.setStatus(AccountStatus.fromString(rs.getString("status")));
        Date reg = rs.getDate("registered_date");
        u.setRegisteredDate(reg == null ? LocalDate.now() : reg.toLocalDate());
        Timestamp last = rs.getTimestamp("last_login");
        u.setLastLogin(last == null ? null : last.toLocalDateTime());
        u.setProfilePicture(nz(rs.getString("profile_picture")));
        u.setSecurityQuestion(nz(rs.getString("security_question")));
        u.setSecurityAnswerHash(nz(rs.getString("security_answer_hash")));
        u.setLevel(StudentLevel.fromString(rs.getString("student_level")));
        u.setLevelDetail(nz(rs.getString("level_detail")));
        return u;
    }

    private static String nz(String s) { return s == null ? "" : s; }

    private static IllegalStateException fail(String what, SQLException e) {
        return new IllegalStateException("Database error - could not " + what + ": " + e.getMessage(), e);
    }
}
