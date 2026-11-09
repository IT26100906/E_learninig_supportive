package com.lms.student.listener;

import com.lms.student.model.Admin;
import com.lms.student.model.User;
import com.lms.student.repository.JdbcUserRepository;
import com.lms.student.repository.AppDataRepository;
import com.lms.student.repository.PaymentRepository;
import com.lms.student.repository.DataMirror;
import com.lms.student.util.DataMigrator;
import com.lms.student.util.DbConfig;
import com.lms.student.util.AppConfig;
import com.lms.student.util.PasswordUtil;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/** Runs once when the application starts: connects to the database, creates the tables and a default admin if none exists. */
@WebListener
public class AppInitListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            AppConfig.ensureFiles();
            JdbcUserRepository repo = JdbcUserRepository.getInstance();
            repo.init();                         // creates table "users" (+ imports old users.txt once)
            PaymentRepository.getInstance().init();   // creates table "payments"
            AppDataRepository.getInstance().init();   // creates table "app_data" (enrollments, reviews, assignments, ... of the module pages)
            DataMirror.getInstance().init();          // readable tables: courses, enrollments, assignments, reviews ... (copied from app_data)
            System.out.println("Database ready: " + DbConfig.describe());
            DataMigrator.importFromH2IfNeeded();   // one-time copy of the old H2 data into MySQL
            boolean hasAdmin = repo.findAll().stream().anyMatch(User::canManageUsers);
            if (!hasAdmin) {
                Admin admin = new Admin("A001", "System Administrator", "admin@lms.com", PasswordUtil.hash("Admin@123"));
                admin.setSecurityQuestion("What is your pet's name?");
                admin.setSecurityAnswerHash(PasswordUtil.hash("admin"));
                repo.create(admin);
                System.out.println("Default admin created -> ID: A001  Password: Admin@123");
            }
        } catch (Exception e) {
            throw new IllegalStateException("Could not initialise the database", e);
        }
    }
}
