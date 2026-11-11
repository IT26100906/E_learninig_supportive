package com.lms.student.config;
import com.lms.student.repository.AppDataRepository;
import com.lms.student.util.AppConfig;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
/** Initializes Course Notes saved-items table; materials are stored in data/uploads/material. */
@WebListener
public class AppInitListener implements ServletContextListener {
 @Override public void contextInitialized(ServletContextEvent event) {
    AppConfig.dataDir();
    AppDataRepository.getInstance().init();
 }
}
