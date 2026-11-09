package com.lms.student.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Reads db.properties (src/main/resources) and opens JDBC connections.
 * Any value can be overridden from the command line, e.g.
 *   -Ddb.type=mysql -Ddb.user=root -Ddb.password=secret
 */
public final class DbConfig {

    private static final Properties PROPS = load();

    private DbConfig() { }

    private static Properties load() {
        Properties p = new Properties();
        try (InputStream in = DbConfig.class.getResourceAsStream("/db.properties")) {
            if (in != null) p.load(in);
        } catch (IOException e) {
            System.err.println("Could not read db.properties, using defaults: " + e.getMessage());
        }
        return p;
    }

    private static String get(String key, String def) {
        String v = System.getProperty(key);
        if (v == null) v = System.getenv(key.toUpperCase().replace('.', '_'));
        if (v == null) v = PROPS.getProperty(key);
        return v == null || v.isBlank() ? def : v.trim();
    }

    /** "h2" (default) or "mysql". */
    public static String type() { return get("db.type", "h2").toLowerCase(); }

    public static boolean isMySql() { return type().startsWith("mysql") || type().startsWith("maria"); }

    public static String url() {
        String custom = get("db.url", null);
        if (custom != null) return custom;
        if (isMySql()) {
            return "jdbc:mysql://localhost:3306/learnhub?createDatabaseIfNotExist=true&useSSL=false"
                 + "&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        }
        File db = new File(AppConfig.dataDir(), "lmsdb");
        return "jdbc:h2:file:" + db.getAbsolutePath().replace('\\', '/') + ";DB_CLOSE_DELAY=-1;AUTO_SERVER=TRUE";
    }

    public static String user()     { return get("db.user", isMySql() ? "root" : "sa"); }
    public static String password() { return get("db.password", ""); }

    /** Name of the database (MySQL: the part after the port in the URL, H2: the file name). */
    public static String databaseName() {
        String u = url();
        try {
            if (isMySql()) {
                String rest = u.substring(u.indexOf("//") + 2);
                rest = rest.substring(rest.indexOf('/') + 1);
                int cut = rest.indexOf('?');
                return cut >= 0 ? rest.substring(0, cut) : rest;
            }
            String f = u.substring(u.indexOf("file:") + 5);
            int cut = f.indexOf(';');
            f = cut >= 0 ? f.substring(0, cut) : f;
            return f.substring(f.lastIndexOf('/') + 1);
        } catch (RuntimeException e) { return "database"; }
    }

    /** Base address of phpMyAdmin (XAMPP default). Change with db.phpmyadmin in db.properties. */
    public static String phpMyAdminUrl() {
        String u = get("db.phpmyadmin", "http://localhost/phpmyadmin");
        return u.endsWith("/") ? u.substring(0, u.length() - 1) : u;
    }

    public static Connection connect() throws SQLException {
        return DriverManager.getConnection(url(), user(), password());
    }

    /** Short text for the start-up banner. */
    public static String describe() {
        return (isMySql() ? "MySQL  " : "H2 file database  ") + url().replaceAll("password=[^&;]*", "password=***");
    }
}
