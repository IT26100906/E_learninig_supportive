package com.lms.student.servlet;

import com.lms.student.util.DbConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Admin-only shortcut to phpMyAdmin: /admin/phpmyadmin sends the admin to the
 * "learnhub" database in phpMyAdmin, where all the data can be viewed.
 * (AuthFilter blocks every /admin/* URL for non-admin users.)
 * The phpMyAdmin address comes from db.phpmyadmin in db.properties.
 */
@WebServlet("/admin/phpmyadmin")
public class AdminPhpMyAdminServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (!DbConfig.isMySql()) {
            flash(req, "warning", "phpMyAdmin works only with MySQL. Set db.type=mysql in db.properties.");
            redirect(req, res, "/admin/dashboard");
            return;
        }
        String db = URLEncoder.encode(DbConfig.databaseName(), StandardCharsets.UTF_8);
        res.sendRedirect(DbConfig.phpMyAdminUrl() + "/index.php?route=/database/structure&db=" + db);
    }
}
