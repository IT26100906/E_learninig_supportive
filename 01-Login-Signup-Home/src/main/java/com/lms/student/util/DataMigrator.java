package com.lms.student.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDateTime;

/**
 * One-time copy of everything that was saved in the old H2 file database (data/lmsdb.mv.db)
 * into MySQL, so the existing students, payments, enrollments, reviews ... show up in phpMyAdmin.
 * Runs automatically at start-up when MySQL is active, and only once
 * (it leaves data/h2-imported-to-mysql.txt behind; delete that file to run it again).
 */
public final class DataMigrator {

    private static final String[] TABLES = { "users", "payments", "app_data" };

    private DataMigrator() { }

    public static void importFromH2IfNeeded() {
        if (!DbConfig.isMySql()) return;
        File dataDir = AppConfig.dataDir();
        File h2File = new File(dataDir, "lmsdb.mv.db");
        File marker = new File(dataDir, "h2-imported-to-mysql.txt");
        if (!h2File.exists() || marker.exists()) return;

        String url = "jdbc:h2:file:" + new File(dataDir, "lmsdb").getAbsolutePath().replace('\\', '/')
                + ";IFEXISTS=TRUE;AUTO_SERVER=TRUE";
        StringBuilder report = new StringBuilder("Imported from H2 on " + LocalDateTime.now() + "\n");
        try (Connection src = DriverManager.getConnection(url, "sa", "");
             Connection dst = DbConfig.connect()) {
            for (String table : TABLES) {
                try {
                    int n = copy(src, dst, table);
                    report.append(table).append(": ").append(n).append(" rows\n");
                    System.out.println("H2 -> MySQL: copied " + n + " rows of '" + table + "'");
                } catch (Exception e) {
                    report.append(table).append(": skipped (").append(e.getMessage()).append(")\n");
                    System.err.println("H2 -> MySQL: could not copy '" + table + "': " + e.getMessage());
                }
            }
            Files.writeString(marker.toPath(), report.toString());
        } catch (Exception e) {
            System.err.println("H2 -> MySQL import failed (the app keeps running; fix the problem and restart to retry): " + e.getMessage());
        }
    }

    private static int copy(Connection src, Connection dst, String table) throws Exception {
        int count = 0;
        try (Statement st = src.createStatement(); ResultSet rs = st.executeQuery("SELECT * FROM " + table)) {
            ResultSetMetaData md = rs.getMetaData();
            int cols = md.getColumnCount();
            StringBuilder names = new StringBuilder(), marks = new StringBuilder();
            for (int i = 1; i <= cols; i++) {
                if (i > 1) { names.append(", "); marks.append(", "); }
                names.append('`').append(md.getColumnLabel(i).toLowerCase()).append('`');
                marks.append('?');
            }
            String sql = "REPLACE INTO `" + table + "` (" + names + ") VALUES (" + marks + ")";
            try (PreparedStatement ps = dst.prepareStatement(sql)) {
                while (rs.next()) {
                    for (int i = 1; i <= cols; i++) {
                        int t = md.getColumnType(i);
                        if (t == Types.CLOB || t == Types.NCLOB || t == Types.LONGVARCHAR) ps.setString(i, rs.getString(i));
                        else ps.setObject(i, rs.getObject(i));
                    }
                    ps.executeUpdate();
                    count++;
                }
            }
        }
        return count;
    }
}
