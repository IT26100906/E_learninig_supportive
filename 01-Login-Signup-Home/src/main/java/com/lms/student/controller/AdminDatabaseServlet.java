package com.lms.student.controller;

import com.lms.student.util.DbConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * Admin-only, READ-ONLY view of the database: /admin/database
 * Lists EVERY table of the database (users, payments, courses, enrollments, pending_invoices, assignments,
 * study_materials, course_reviews, app_data ...) and shows the rows of the selected table, 25 per page.
 * Works with both H2 and MySQL because the table list comes from JDBC metadata, so a table added later shows up by itself.
 * Columns that hold passwords / hashes / security answers are never shown.
 * (AuthFilter blocks every /admin/* URL for non-admin users.)
 */
@WebServlet("/admin/database")
public class AdminDatabaseServlet extends BaseServlet {

    private static final int PAGE_SIZE = 25;
    private static final int MAX_CELL = 160;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try (Connection c = DbConfig.connect()) {
            DatabaseMetaData md = c.getMetaData();

            // 1) all tables + row counts
            List<String> names = new ArrayList<>();
            try (ResultSet rs = md.getTables(c.getCatalog(), c.getSchema(), "%", new String[]{"TABLE"})) {
                while (rs.next()) names.add(rs.getString("TABLE_NAME"));
            }
            names.sort(String.CASE_INSENSITIVE_ORDER);
            String q = md.getIdentifierQuoteString();
            if (q == null || q.isBlank()) q = "\"";

            List<Map<String, Object>> tables = new ArrayList<>();
            for (String n : names) {
                Map<String, Object> t = new LinkedHashMap<>();
                t.put("name", n);
                t.put("count", countRows(c, q + n + q));
                tables.add(t);
            }
            req.setAttribute("tables", tables);
            req.setAttribute("dbName", DbConfig.databaseName());
            req.setAttribute("dbKind", DbConfig.isMySql() ? "MySQL / MariaDB" : "H2 file database");

            // 2) the selected table (must be one of the names found above - never raw user input in the SQL)
            String selected = param(req, "table");
            String match = null;
            for (String n : names) if (n.equalsIgnoreCase(selected)) match = n;
            if (match == null && !names.isEmpty()) {
                match = names.contains("users") ? "users" : names.contains("USERS") ? "USERS" : names.get(0);
            }

            if (match != null) {
                String quoted = q + match + q;
                long total = countRows(c, quoted);
                int pages = (int) Math.max(1, (total + PAGE_SIZE - 1) / PAGE_SIZE);
                int page = 1;
                try { page = Integer.parseInt(param(req, "page")); } catch (NumberFormatException ignored) { }
                page = Math.min(Math.max(page, 1), pages);

                List<String> pk = new ArrayList<>();
                try (ResultSet rs = md.getPrimaryKeys(c.getCatalog(), c.getSchema(), match)) {
                    while (rs.next()) pk.add(rs.getString("COLUMN_NAME"));
                }
                StringBuilder order = new StringBuilder();
                for (String col : pk) order.append(order.length() == 0 ? " ORDER BY " : ", ").append(q).append(col).append(q);

                List<String> cols = new ArrayList<>();
                List<Integer> keep = new ArrayList<>();
                List<List<String>> rows = new ArrayList<>();
                String sql = "SELECT * FROM " + quoted + order + " LIMIT " + PAGE_SIZE + " OFFSET " + ((page - 1) * PAGE_SIZE);
                try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
                    ResultSetMetaData rm = rs.getMetaData();
                    for (int i = 1; i <= rm.getColumnCount(); i++) {
                        if (isSecret(rm.getColumnLabel(i))) continue;
                        keep.add(i);
                        cols.add(rm.getColumnLabel(i));
                    }
                    while (rs.next()) {
                        List<String> row = new ArrayList<>();
                        for (int i : keep) row.add(cell(rs.getString(i)));
                        rows.add(row);
                    }
                }
                int from = total == 0 ? 0 : (page - 1) * PAGE_SIZE + 1;
                req.setAttribute("selected", match);
                req.setAttribute("cols", cols);
                req.setAttribute("rows", rows);
                req.setAttribute("pk", pk);
                req.setAttribute("total", total);
                req.setAttribute("page", page);
                req.setAttribute("pages", pages);
                req.setAttribute("from", from);
                req.setAttribute("to", from == 0 ? 0 : from + rows.size() - 1);
            }
        } catch (SQLException e) {
            req.setAttribute("dbError", e.getMessage());
        }
        render(req, res, "admin/database");
    }

    private static long countRows(Connection c, String quotedTable) {
        try (Statement st = c.createStatement(); ResultSet rs = st.executeQuery("SELECT COUNT(*) FROM " + quotedTable)) {
            return rs.next() ? rs.getLong(1) : 0;
        } catch (SQLException e) {
            return 0;
        }
    }

    /** password, password_hash, security_answer_hash ... are never displayed. */
    private static boolean isSecret(String column) {
        String n = column == null ? "" : column.toLowerCase();
        return n.contains("password") || n.contains("hash") || n.contains("security_answer");
    }

    private static String cell(String v) {
        if (v == null) return null;
        return v.length() > MAX_CELL ? v.substring(0, MAX_CELL) + " ..." : v;
    }
}
