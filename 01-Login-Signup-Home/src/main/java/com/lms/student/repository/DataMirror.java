package com.lms.student.repository;

import com.lms.student.util.DbConfig;
import com.lms.student.util.Json;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.*;

/**
 * Keeps READABLE database tables up to date with everything the module pages save.
 *
 * The pages store their data as JSON text in table "app_data" (one row per key). That is hard to read in phpMyAdmin,
 * so every time such a value is saved, this class also rewrites ordinary tables from it:
 *
 *   courses           course catalogue (built-in list + the admin's add / edit / delete)
 *   enrollments       who is enrolled in which course   (recorded_by STUDENT = student's own page, ADMIN = admin list)
 *   payments          payments (students' real payments + the admin payment list, origin column tells which)
 *   pending_invoices  unpaid invoices of each student
 *   assignments       assignments + submissions + marks
 *   study_materials   study materials list
 *   course_reviews    course reviews
 *
 * The student details themselves are in table "users". Direction is app -> database only: change something in the
 * website and the tables update at once; editing a mirror table by hand in phpMyAdmin does not change the website.
 * A failure here never breaks saving: it is only printed to the console.
 */
public final class DataMirror {

    private static final DataMirror INSTANCE = new DataMirror();
    public static DataMirror getInstance() { return INSTANCE; }
    private DataMirror() { }

    private interface Work { void run(Connection c) throws SQLException; }

    // ------------------------------------------------------------------ setup

    /** Creates the tables, loads the course catalogue and copies everything already saved in app_data. */
    public void init() {
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement()) {
            st.executeUpdate("CREATE TABLE IF NOT EXISTS courses (" +
                " course_id VARCHAR(12) NOT NULL PRIMARY KEY, level_code VARCHAR(12), name VARCHAR(150) NOT NULL," +
                " category VARCHAR(60), difficulty VARCHAR(20), fee DECIMAL(12,2), duration_weeks INT, is_free BOOLEAN," +
                " instructor VARCHAR(100), schedule VARCHAR(100), lang VARCHAR(80), seats INT, seats_taken INT," +
                " descr VARCHAR(1000), topics VARCHAR(1000))");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS enrollments (" +
                " recorded_by VARCHAR(8) NOT NULL, student_id VARCHAR(12) NOT NULL, course_id VARCHAR(12) NOT NULL," +
                " course_name VARCHAR(150), enrolled_date VARCHAR(10), progress_pct INT, lessons_done INT, payment_status VARCHAR(12)," +
                " PRIMARY KEY (recorded_by, student_id, course_id))");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS pending_invoices (" +
                " student_id VARCHAR(12) NOT NULL, invoice_no VARCHAR(30) NOT NULL, course_name VARCHAR(150)," +
                " descr VARCHAR(200), amount DECIMAL(12,2), due_date VARCHAR(10), PRIMARY KEY (student_id, invoice_no))");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS assignments (" +
                " owner_id VARCHAR(12) NOT NULL, assignment_id INT NOT NULL, title VARCHAR(200), course_name VARCHAR(150)," +
                " due_date VARCHAR(10), total_marks INT, status VARCHAR(12), score INT, feedback VARCHAR(500)," +
                " submitted_date VARCHAR(10), file_name VARCHAR(200), descr VARCHAR(1000), PRIMARY KEY (owner_id, assignment_id))");
            try { st.executeUpdate("ALTER TABLE assignments ADD COLUMN level_code VARCHAR(12)"); }
            catch (SQLException exists) { /* column is already there */ }
            st.executeUpdate("CREATE TABLE IF NOT EXISTS study_materials (" +
                " owner_id VARCHAR(12) NOT NULL, material_id INT NOT NULL, title VARCHAR(200), course_name VARCHAR(150)," +
                " material_type VARCHAR(12), size_text VARCHAR(30), upload_date VARCHAR(10), downloads INT, descr VARCHAR(1000)," +
                " PRIMARY KEY (owner_id, material_id))");
            st.executeUpdate("CREATE TABLE IF NOT EXISTS course_reviews (" +
                " review_id INT NOT NULL PRIMARY KEY, student_id VARCHAR(20), reviewer_name VARCHAR(100), anonymous BOOLEAN," +
                " course_name VARCHAR(150), rating INT, title VARCHAR(150), review_text VARCHAR(2000)," +
                " review_date VARCHAR(10), helpful_votes INT)");
        } catch (SQLException e) {
            System.err.println("DataMirror: could not create the tables: " + e.getMessage());
            return;
        }
        rebuildAll();
    }

    /** Re-creates every mirror table from what is stored in app_data (runs at start-up). */
    private void rebuildAll() {
        List<String[]> rows = new ArrayList<>();
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT owner_id, data_key, data_value FROM app_data")) {
            while (rs.next()) rows.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3)});
        } catch (SQLException e) {
            System.err.println("DataMirror: could not read app_data: " + e.getMessage());
        }
        String overlay = "{}";
        for (String[] r : rows) if ("courses-overlay".equals(r[1])) overlay = r[2];
        apply(AppDataRepository.SHARED, "courses-overlay", overlay);      // courses first (names are used by the others)
        for (String[] r : rows) if (!"courses-overlay".equals(r[1])) apply(r[0], r[1], r[2]);
        refreshAssignments();
        System.out.println("Readable tables ready. Rows: courses=" + count("courses") + ", enrollments=" + count("enrollments")
            + ", payments=" + count("payments") + ", users=" + count("users"));
        if (count("courses") == 0) System.err.println("DataMirror: the courses table is EMPTY - check that courses-seed.json is in src/main/resources and rebuild the project.");
    }

    // ------------------------------------------------------------------ called by StoreServlet

    /** A value was saved: refresh the table that belongs to this key (other keys are ignored). */
    public void apply(String owner, String key, String json) {
        if ("adm-asg".equals(key) || key.startsWith("asg-s-") || key.startsWith("asg-g-")) { refreshAssignments(); return; }
        Object v = Json.parse(json);
        if (v == null) return;
        try {
            tx(c -> {
                switch (key) {
                    case "courses-overlay": courses(c, v); break;
                    case "enrolled":        enrollments(c, "STUDENT", owner, v); break;
                    case "adm-enr":         enrollments(c, "ADMIN", null, v); break;
                    case "reviews":         reviews(c, v); break;
                    case "notes":           materials(c, owner, v); break;
                    case "pay-pending":     invoices(c, owner, v); break;
                    case "adm-pay":         adminPayments(c, v); break;
                    default: break;
                }
            });
        } catch (SQLException | RuntimeException e) {
            System.err.println("DataMirror: '" + key + "' was saved but not copied to its table: " + e);
            e.printStackTrace();
        }
    }

    /** A value was deleted. */
    public void remove(String owner, String key) {
        apply(owner, key, "courses-overlay".equals(key) ? "{}" : "[]");
    }

    /** All private values of one user were reset. */
    public void removeOwner(String owner) {
        try {
            tx(c -> {
                exec(c, "DELETE FROM enrollments WHERE recorded_by = 'STUDENT' AND student_id = ?", owner);
                exec(c, "DELETE FROM assignments WHERE owner_id = ?", owner);
                exec(c, "DELETE FROM study_materials WHERE owner_id = ?", owner);
                exec(c, "DELETE FROM pending_invoices WHERE student_id = ?", owner);
            });
        } catch (SQLException e) { System.err.println("DataMirror: " + e.getMessage()); }
    }

    /** A student account was deleted: remove his / her rows from the readable tables (payments are kept as records). */
    public void removeStudent(String id) {
        removeOwner(id);
        try { tx(c -> exec(c, "DELETE FROM enrollments WHERE student_id = ?", id)); }
        catch (SQLException e) { System.err.println("DataMirror: " + e.getMessage()); }
    }

    // ------------------------------------------------------------------ one method per table

    private void courses(Connection c, Object overlay) throws SQLException {
        exec(c, "DELETE FROM courses");
        for (Object o : Json.list(Json.parse(seedText()))) insertCourse(c, o);
        Object edited = Json.raw(overlay, "edited");
        if (edited instanceof Map) for (Object o : ((Map<?, ?>) edited).values()) {
            exec(c, "DELETE FROM courses WHERE course_id = ?", Json.str(o, "id"));
            insertCourse(c, o);
        }
        for (Object o : Json.list(Json.raw(overlay, "added"))) {
            exec(c, "DELETE FROM courses WHERE course_id = ?", Json.str(o, "id"));
            insertCourse(c, o);
        }
        for (Object id : Json.list(Json.raw(overlay, "deleted"))) exec(c, "DELETE FROM courses WHERE course_id = ?", String.valueOf(id));
    }

    private void insertCourse(Connection c, Object o) throws SQLException {
        String id = Json.str(o, "id");
        if (id.isEmpty()) return;
        StringBuilder topics = new StringBuilder();
        for (Object t : Json.list(Json.raw(o, "topics"))) { if (topics.length() > 0) topics.append(", "); topics.append(t); }
        try (PreparedStatement ps = c.prepareStatement("INSERT INTO courses (course_id, level_code, name, category, difficulty, fee," +
                " duration_weeks, is_free, instructor, schedule, lang, seats, seats_taken, descr, topics) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
            ps.setString(1, cut(id, 12)); ps.setString(2, cut(Json.str(o, "lv"), 12)); ps.setString(3, cut(Json.str(o, "name"), 150));
            ps.setString(4, cut(Json.str(o, "cat"), 60)); ps.setString(5, cut(Json.str(o, "diff"), 20));
            ps.setDouble(6, Json.num(o, "fee", 0)); ps.setInt(7, Json.intval(o, "weeks", 0));
            ps.setBoolean(8, Boolean.TRUE.equals(Json.raw(o, "free")) || Json.num(o, "fee", 0) <= 0);
            ps.setString(9, cut(Json.str(o, "teacher"), 100)); ps.setString(10, cut(Json.str(o, "schedule"), 100));
            ps.setString(11, cut(Json.str(o, "lang"), 80)); ps.setInt(12, Json.intval(o, "seats", 0)); ps.setInt(13, Json.intval(o, "taken", 0));
            ps.setString(14, cut(Json.str(o, "desc"), 1000)); ps.setString(15, cut(topics.toString(), 1000));
            ps.executeUpdate();
        }
    }

    private void enrollments(Connection c, String by, String owner, Object list) throws SQLException {
        if (owner != null) exec(c, "DELETE FROM enrollments WHERE recorded_by = ? AND student_id = ?", by, owner);
        else exec(c, "DELETE FROM enrollments WHERE recorded_by = ?", by);
        Map<String, String> names = new HashMap<>();
        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT course_id, name FROM courses")) {
            while (rs.next()) names.put(rs.getString(1), rs.getString(2));
        }
        Set<String> seen = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement("INSERT INTO enrollments (recorded_by, student_id, course_id, course_name," +
                " enrolled_date, progress_pct, lessons_done, payment_status) VALUES (?,?,?,?,?,?,?,?)")) {
            for (Object e : Json.list(list)) {
                String sid = owner != null ? owner : Json.str(e, "sid");
                String cid = Json.str(e, owner != null ? "id" : "cid");
                if (sid.isEmpty() || cid.isEmpty() || !seen.add(sid + "|" + cid)) continue;
                Object paid = Json.raw(e, "paid");
                String pay = Boolean.FALSE.equals(paid) ? "FREE_SLOT" : "free".equals(paid) ? "FREE_COURSE" : "PAID";
                ps.setString(1, by); ps.setString(2, cut(sid, 12)); ps.setString(3, cut(cid, 12));
                ps.setString(4, cut(names.getOrDefault(cid, ""), 150)); ps.setString(5, cut(Json.str(e, "date"), 10));
                ps.setInt(6, Json.intval(e, "progress", 0)); ps.setInt(7, Json.list(Json.raw(e, "done")).size()); ps.setString(8, pay);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void reviews(Connection c, Object list) throws SQLException {
        exec(c, "DELETE FROM course_reviews");
        Set<Integer> seen = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement("INSERT INTO course_reviews (review_id, student_id, reviewer_name, anonymous," +
                " course_name, rating, title, review_text, review_date, helpful_votes) VALUES (?,?,?,?,?,?,?,?,?,?)")) {
            for (Object r : Json.list(list)) {
                int id = Json.intval(r, "id", 0);
                if (id <= 0 || !seen.add(id)) continue;
                ps.setInt(1, id); ps.setString(2, cut(Json.str(r, "uid"), 20)); ps.setString(3, cut(Json.str(r, "name"), 100));
                ps.setBoolean(4, Boolean.TRUE.equals(Json.raw(r, "anon"))); ps.setString(5, cut(Json.str(r, "course"), 150));
                ps.setInt(6, Json.intval(r, "rating", 0)); ps.setString(7, cut(Json.str(r, "title"), 150));
                ps.setString(8, cut(Json.str(r, "text"), 2000)); ps.setString(9, cut(Json.str(r, "date"), 10)); ps.setInt(10, Json.intval(r, "helpful", 0));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /**
     * Table "assignments" is rebuilt from app_data every time an assignment, a submission or a mark changes:
     *   owner_id = '*'        one row per assignment the admin created (status ASSIGNED, with its learner level)
     *   owner_id = student id one row per submission (status SUBMITTED, or GRADED once the admin gave marks)
     */
    public void refreshAssignments() {
        List<String[]> rows = new ArrayList<>();
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement();
             ResultSet rs = st.executeQuery("SELECT owner_id, data_key, data_value FROM app_data WHERE data_key = 'adm-asg' OR data_key LIKE 'asg-s-%' OR data_key LIKE 'asg-g-%'")) {
            while (rs.next()) rows.add(new String[]{rs.getString(1), rs.getString(2), rs.getString(3)});
        } catch (SQLException e) { System.err.println("DataMirror: could not read the assignments: " + e.getMessage()); return; }
        try {
            tx(c -> {
                exec(c, "DELETE FROM assignments");
                Map<Integer, Object> defs = new LinkedHashMap<>();
                Map<String, Object> grades = new HashMap<>();
                for (String[] r : rows) {
                    if ("adm-asg".equals(r[1])) {
                        for (Object a : Json.list(Json.parse(r[2]))) { int id = Json.intval(a, "id", 0); if (id > 0) defs.putIfAbsent(id, a); }
                    } else if (r[1].startsWith("asg-g-")) {
                        grades.put(r[0] + "|" + r[1].substring(6), Json.parse(r[2]));
                    }
                }
                try (PreparedStatement ps = c.prepareStatement("INSERT INTO assignments (owner_id, assignment_id, title, course_name, due_date," +
                        " total_marks, status, score, feedback, submitted_date, file_name, descr, level_code) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)")) {
                    for (Map.Entry<Integer, Object> e : defs.entrySet()) {
                        Object a = e.getValue();
                        fill(ps, "*", e.getKey(), a, "ASSIGNED", null, "", "", "");
                        ps.addBatch();
                    }
                    Set<String> done = new HashSet<>();
                    for (String[] r : rows) {
                        if (!r[1].startsWith("asg-s-") || AppDataRepository.SHARED.equals(r[0])) continue;
                        int id; try { id = Integer.parseInt(r[1].substring(6)); } catch (NumberFormatException ex) { continue; }
                        Object def = defs.get(id), sub = Json.parse(r[2]);
                        if (def == null || sub == null || !done.add(r[0] + "|" + id)) continue;   // assignment was deleted by the admin
                        Object g = grades.get(r[0] + "|" + id);
                        fill(ps, r[0], id, def, g != null ? "GRADED" : "SUBMITTED", g == null ? null : Json.raw(g, "score"),
                             g == null ? "" : Json.str(g, "feedback"), Json.str(sub, "submitted"), Json.str(sub, "file"));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
            });
        } catch (SQLException | RuntimeException e) {
            System.err.println("DataMirror: assignments were saved but not copied to their table: " + e);
        }
    }

    private static void fill(PreparedStatement ps, String owner, int id, Object a, String status, Object score, String feedback, String submitted, String file) throws SQLException {
        ps.setString(1, cut(owner, 12)); ps.setInt(2, id); ps.setString(3, cut(Json.str(a, "title"), 200)); ps.setString(4, cut(Json.str(a, "course"), 150));
        ps.setString(5, cut(Json.str(a, "due"), 10)); ps.setInt(6, Json.intval(a, "marks", 0)); ps.setString(7, status);
        if (score instanceof Double) ps.setInt(8, (int) Math.round((Double) score)); else ps.setNull(8, Types.INTEGER);
        ps.setString(9, cut(feedback, 500)); ps.setString(10, cut(submitted, 10)); ps.setString(11, cut(file, 200));
        ps.setString(12, cut(Json.str(a, "desc"), 1000)); ps.setString(13, cut(Json.str(a, "lv"), 12));
    }

    private void materials(Connection c, String owner, Object list) throws SQLException {
        exec(c, "DELETE FROM study_materials WHERE owner_id = ?", owner);
        Set<Integer> seen = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement("INSERT INTO study_materials (owner_id, material_id, title, course_name, material_type," +
                " size_text, upload_date, downloads, descr) VALUES (?,?,?,?,?,?,?,?,?)")) {
            for (Object m : Json.list(list)) {
                int id = Json.intval(m, "id", 0);
                if (id <= 0 || !seen.add(id)) continue;
                ps.setString(1, owner); ps.setInt(2, id); ps.setString(3, cut(Json.str(m, "title"), 200)); ps.setString(4, cut(Json.str(m, "course"), 150));
                ps.setString(5, cut(Json.str(m, "type"), 12)); ps.setString(6, cut(Json.str(m, "size"), 30)); ps.setString(7, cut(Json.str(m, "date"), 10));
                ps.setInt(8, Json.intval(m, "down", 0)); ps.setString(9, cut(Json.str(m, "desc"), 1000));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private void invoices(Connection c, String owner, Object list) throws SQLException {
        exec(c, "DELETE FROM pending_invoices WHERE student_id = ?", owner);
        Set<String> seen = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement("INSERT INTO pending_invoices (student_id, invoice_no, course_name, descr, amount, due_date)" +
                " VALUES (?,?,?,?,?,?)")) {
            for (Object p : Json.list(list)) {
                String no = Json.str(p, "id");
                if (no.isEmpty() || !seen.add(no)) continue;
                ps.setString(1, owner); ps.setString(2, cut(no, 30)); ps.setString(3, cut(Json.str(p, "course"), 150));
                ps.setString(4, cut(Json.str(p, "desc"), 200)); ps.setDouble(5, Json.num(p, "amount", 0)); ps.setString(6, cut(Json.str(p, "due"), 10));
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /** The admin's payment list goes into the payments table too (origin = ADMIN); real student payments stay untouched. */
    private void adminPayments(Connection c, Object list) throws SQLException {
        exec(c, "DELETE FROM payments WHERE origin = 'ADMIN'");
        Set<String> seen = new HashSet<>();
        for (Object p : Json.list(list)) {
            String rc = cut(Json.str(p, "rcpt"), 40);
            if (rc.isEmpty() || Json.str(p, "sid").isEmpty() || !seen.add(rc)) continue;
            boolean taken;
            try (PreparedStatement q = c.prepareStatement("SELECT 1 FROM payments WHERE receipt_no = ?")) {
                q.setString(1, rc);
                try (ResultSet rs = q.executeQuery()) { taken = rs.next(); }
            }
            if (taken) continue;
            try (PreparedStatement ps = c.prepareStatement("INSERT INTO payments (receipt_no, student_id, course, descr, amount, pay_date," +
                    " pay_method, pay_ref, origin) VALUES (?,?,?,?,?,?,?,?,'ADMIN')")) {
                ps.setString(1, rc); ps.setString(2, cut(Json.str(p, "sid"), 12)); ps.setString(3, cut(Json.str(p, "course"), 150));
                ps.setString(4, cut(Json.str(p, "desc"), 200)); ps.setDouble(5, Json.num(p, "amount", 0)); ps.setString(6, cut(Json.str(p, "date"), 10));
                ps.setString(7, cut(Json.str(p, "method"), 30)); ps.setString(8, cut(Json.str(p, "ref"), 120));
                ps.executeUpdate();
            }
        }
    }

    // ------------------------------------------------------------------ helpers

    private void tx(Work w) throws SQLException {
        try (Connection c = DbConfig.connect()) {
            c.setAutoCommit(false);
            try { w.run(c); c.commit(); }
            catch (SQLException | RuntimeException e) { c.rollback(); throw e; }
        }
    }

    private static void exec(Connection c, String sql, String... params) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) ps.setString(i + 1, params[i]);
            ps.executeUpdate();
        }
    }

    private static int count(String table) {
        try (Connection c = DbConfig.connect(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM " + table)) {
            return rs.next() ? rs.getInt(1) : -1;
        } catch (SQLException e) { return -1; }
    }

    private static String cut(String s, int n) { return s == null ? "" : s.length() > n ? s.substring(0, n) : s; }

    private static String seedText() {
        try (InputStream in = DataMirror.class.getResourceAsStream("/courses-seed.json")) {
            return in == null ? "[]" : new String(in.readAllBytes(), StandardCharsets.UTF_8);
        } catch (IOException e) { return "[]"; }
    }
}
