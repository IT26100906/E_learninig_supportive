package com.lms.student.repository;

import com.lms.student.util.DbConfig;

import java.sql.*;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Saves the data of the module pages (enrollments, reviews, assignments, payments list, course changes ...)
 * in the database, table "app_data": one row per (owner, key) holding that page's data as JSON text.
 *  owner = a user id (private to that user)  or  "*" (shared by everybody, e.g. course catalogue changes, reviews).
 * PreparedStatement only.
 */
public class AppDataRepository {

    public static final String SHARED = "*";

    private static final AppDataRepository INSTANCE = new AppDataRepository();
    public static AppDataRepository getInstance() { return INSTANCE; }
    private AppDataRepository() { }

    public void init() {
        String clob = DbConfig.isMySql() ? "MEDIUMTEXT" : "CLOB";
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS app_data (" +
                " owner_id   VARCHAR(12) NOT NULL," +
                " data_key   VARCHAR(40) NOT NULL," +
                " data_value " + clob + " NOT NULL," +
                " updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                " PRIMARY KEY (owner_id, data_key))");
        } catch (SQLException e) {
            throw new IllegalStateException("Could not create table app_data", e);
        }
    }

    /** All keys of one owner (key -> JSON text). */
    public Map<String, String> findByOwner(String owner) {
        Map<String, String> out = new LinkedHashMap<>();
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("SELECT data_key, data_value FROM app_data WHERE owner_id = ?")) {
            ps.setString(1, owner);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.put(rs.getString(1), rs.getString(2));
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not read app_data", e);
        }
        return out;
    }

    /** Every row whose key starts with the prefix, for ALL owners: [owner, key, value] (admin submissions / marks list). */
    public java.util.List<String[]> findByKeyPrefix(String prefix) {
        java.util.List<String[]> out = new java.util.ArrayList<>();
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("SELECT owner_id, data_key, data_value FROM app_data WHERE data_key LIKE ? AND owner_id <> ?")) {
            ps.setString(1, prefix + "%");   // prefixes are fixed text like "asg-s-" (no wildcard characters)
            ps.setString(2, SHARED);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3)});
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not read app_data", e);
        }
        return out;
    }

    /** Inserts or replaces one value. */
    public synchronized void put(String owner, String key, String json) {
        try (Connection c = DbConfig.connect()) {
            int n;
            try (PreparedStatement up = c.prepareStatement(
                    "UPDATE app_data SET data_value = ?, updated_at = CURRENT_TIMESTAMP WHERE owner_id = ? AND data_key = ?")) {
                up.setString(1, json); up.setString(2, owner); up.setString(3, key);
                n = up.executeUpdate();
            }
            if (n == 0) {
                try (PreparedStatement in = c.prepareStatement(
                        "INSERT INTO app_data (owner_id, data_key, data_value) VALUES (?,?,?)")) {
                    in.setString(1, owner); in.setString(2, key); in.setString(3, json);
                    in.executeUpdate();
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not save app_data", e);
        }
    }

    public void delete(String owner, String key) {
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("DELETE FROM app_data WHERE owner_id = ? AND data_key = ?")) {
            ps.setString(1, owner); ps.setString(2, key); ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Could not delete app_data", e);
        }
    }

    public void deleteOwner(String owner) {
        try (Connection c = DbConfig.connect();
             PreparedStatement ps = c.prepareStatement("DELETE FROM app_data WHERE owner_id = ?")) {
            ps.setString(1, owner); ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Could not delete app_data", e);
        }
    }
}
