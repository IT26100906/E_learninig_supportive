package com.lms.student.repository;

import com.lms.student.util.DbConfig;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/** Stores the payments made by students (table "payments") so the admin can see them. PreparedStatement only. */
public class PaymentRepository {

    /** One payment row. */
    public static class Payment {
        public String rcpt, studentId, course, desc, date, method, ref;
        public double amount;
    }

    private static final PaymentRepository INSTANCE = new PaymentRepository();
    public static PaymentRepository getInstance() { return INSTANCE; }
    private PaymentRepository() { }

    public void init() {
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS payments (" +
                " receipt_no VARCHAR(40) NOT NULL PRIMARY KEY," +
                " student_id VARCHAR(12) NOT NULL," +
                " course     VARCHAR(150) NOT NULL," +
                " descr      VARCHAR(200)," +
                " amount     DECIMAL(12,2) NOT NULL," +
                " pay_date   VARCHAR(10) NOT NULL," +
                " pay_method VARCHAR(30) NOT NULL," +
                " pay_ref    VARCHAR(120)," +
                " origin     VARCHAR(10) DEFAULT 'STUDENT')");
            // tables made by an older version do not have the origin column yet
            try { st.executeUpdate("ALTER TABLE payments ADD COLUMN origin VARCHAR(10) DEFAULT 'STUDENT'"); }
            catch (SQLException ignored) { /* already there */ }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not create table payments", e);
        }
    }

    /** Saves a payment and gives it a unique receipt number (RCT-yyyymmdd-STUDENTID-n). */
    public synchronized Payment add(Payment p) {
        try (Connection c = DbConfig.connect()) {
            int n = 1;
            String base = "RCT-" + p.date.replace("-", "") + "-" + p.studentId + "-";
            while (exists(c, base + String.format("%02d", n))) n++;
            p.rcpt = base + String.format("%02d", n);
            try (PreparedStatement ps = c.prepareStatement(
                    "INSERT INTO payments (receipt_no, student_id, course, descr, amount, pay_date, pay_method, pay_ref) VALUES (?,?,?,?,?,?,?,?)")) {
                ps.setString(1, p.rcpt); ps.setString(2, p.studentId); ps.setString(3, p.course); ps.setString(4, p.desc);
                ps.setDouble(5, p.amount); ps.setString(6, p.date); ps.setString(7, p.method); ps.setString(8, p.ref);
                ps.executeUpdate();
            }
            return p;
        } catch (SQLException e) {
            throw new IllegalStateException("Could not save the payment", e);
        }
    }

    private boolean exists(Connection c, String rcpt) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement("SELECT 1 FROM payments WHERE receipt_no = ?")) {
            ps.setString(1, rcpt);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    public List<Payment> findAll() {
        List<Payment> out = new ArrayList<>();
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT receipt_no, student_id, course, descr, amount, pay_date, pay_method, pay_ref FROM payments WHERE origin IS NULL OR origin = 'STUDENT' ORDER BY pay_date DESC, receipt_no DESC")) {
            while (rs.next()) {
                Payment p = new Payment();
                p.rcpt = rs.getString(1); p.studentId = rs.getString(2); p.course = rs.getString(3); p.desc = rs.getString(4);
                p.amount = rs.getDouble(5); p.date = rs.getString(6); p.method = rs.getString(7); p.ref = rs.getString(8);
                out.add(p);
            }
        } catch (SQLException e) {
            throw new IllegalStateException("Could not read payments", e);
        }
        return out;
    }

    public void delete(String rcpt) {
        try (Connection c = DbConfig.connect(); PreparedStatement ps = c.prepareStatement("DELETE FROM payments WHERE receipt_no = ?")) {
            ps.setString(1, rcpt); ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException("Could not delete the payment", e);
        }
    }
}
