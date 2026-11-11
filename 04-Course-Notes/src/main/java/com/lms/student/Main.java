package com.lms.student;

import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * Starts an embedded Tomcat server so the whole web application can be launched
 * by simply running this class from IntelliJ IDEA.
 *
 * Open http://localhost:8080/ after starting.
 */
public class Main {

    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getProperty("port", "8080"));

        File root = findProjectRoot();
        File webapp = new File(root, "src/main/webapp");
        File classes = new File(root, "target/classes");

        // data/ (database file + profile pictures) lives inside the project folder (unless -Dlms.data.dir is given)
        if (System.getProperty("lms.data.dir") == null) {
            System.setProperty("lms.data.dir", new File(root, "data").getAbsolutePath());
        }

        Tomcat tomcat = new Tomcat();
        tomcat.setBaseDir(new File(root, "target/tomcat").getAbsolutePath());
        tomcat.setPort(port);
        tomcat.getConnector().setProperty("address", "127.0.0.1");

        if (!classes.isDirectory()) {
            throw new IllegalStateException("Compiled classes missing: " + classes + ". In IntelliJ use Maven > Lifecycle > compile, then Run Main.");
        }
        Context ctx = tomcat.addWebapp("", webapp.getAbsolutePath());

        // Embedded Tomcat does not automatically inherit the server's global
        // default servlet configuration. Without this mapping JSP pages render,
        // but /css, /js, /images and /media return 404 (plain white page).
        // Path-specific /js/store.js is still handled by @WebServlet, because
        // exact servlet mappings take priority over path mappings.
        org.apache.catalina.servlets.DefaultServlet staticServlet =
                new org.apache.catalina.servlets.DefaultServlet();
        org.apache.catalina.Wrapper assets = Tomcat.addServlet(ctx, "moduleStaticAssets", staticServlet);
        assets.setLoadOnStartup(1);
        ctx.addServletMappingDecoded("/css/*", "moduleStaticAssets");
        ctx.addServletMappingDecoded("/js/*", "moduleStaticAssets");
        ctx.addServletMappingDecoded("/images/*", "moduleStaticAssets");
        ctx.addServletMappingDecoded("/media/*", "moduleStaticAssets");


        // Tell Tomcat where the compiled classes are (so @WebServlet / @WebFilter are found)
        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(
            resources, "/WEB-INF/classes", classes.getAbsolutePath(), "/"));
        ctx.setResources(resources);

        tomcat.start();
        System.out.println("=======================================================");
        System.out.println(" LearnHub - course-notes (LOCAL DEMO)");
        System.out.println(" Running on:  http://localhost:" + port + "/");
        System.out.println(" Project:     " + root.getAbsolutePath());
        System.out.println(" Data folder: " + System.getProperty("lms.data.dir"));
        System.out.println(" Database:    " + com.lms.student.util.DbConfig.describe());
        System.out.println("=======================================================");
        tomcat.getServer().await();
    }

    /**
     * Finds the folder that contains pom.xml and src/main/webapp, no matter where the program
     * was started from (the project folder itself, its parent folder, or a sub-folder).
     */
    private static File findProjectRoot() {
        java.util.List<File> starts = new java.util.ArrayList<>();
        starts.add(new File(System.getProperty("user.dir", ".")));
        try {
            starts.add(new File(Main.class.getProtectionDomain().getCodeSource().getLocation().toURI()));
        } catch (Exception ignored) { }
        for (File start : starts) {
            File d = start.getAbsoluteFile();
            for (int i = 0; i < 8 && d != null; i++, d = d.getParentFile()) {
                if (new File(d, "pom.xml").isFile() && new File(d, "src/main/webapp").isDirectory()) {
                    return d;
                }
                // IntelliJ may use the extracted ZIP parent as working directory.
                File child = new File(d, "04-Course-Notes");
                if (new File(child, "pom.xml").isFile() && new File(child, "src/main/webapp").isDirectory()) {
                    return child;
                }
            }
        }
        throw new IllegalStateException("Could not locate 04-Course-Notes project. Open the folder containing pom.xml in IntelliJ IDEA.");
    }
}
