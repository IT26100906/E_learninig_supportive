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
        tomcat.getConnector();

        if (!classes.isDirectory()) {
            throw new IllegalStateException("Run Maven compile first: " + classes);
        }
        Context ctx = tomcat.addWebapp("", webapp.getAbsolutePath());

        // Register the default servlet explicitly for embedded Tomcat.
        // Without these mappings JSPs render but original CSS/JS/images return 404.
        org.apache.catalina.Wrapper assets = Tomcat.addServlet(
                ctx, "memberStaticAssets", new org.apache.catalina.servlets.DefaultServlet());
        assets.setLoadOnStartup(1);
        ctx.addServletMappingDecoded("/css/*", "memberStaticAssets");
        ctx.addServletMappingDecoded("/js/*", "memberStaticAssets");
        ctx.addServletMappingDecoded("/images/*", "memberStaticAssets");
        ctx.addServletMappingDecoded("/media/*", "memberStaticAssets");


        // Tell Tomcat where the compiled classes are (so @WebServlet / @WebFilter are found)
        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(
            resources, "/WEB-INF/classes", classes.getAbsolutePath(), "/"));
        ctx.setResources(resources);

        tomcat.start();
        System.out.println("=======================================================");
        System.out.println(" LearnHub - Student Account Management");
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
                File child = new File(d, "01-Login-Signup-Home");
                if (new File(child, "pom.xml").isFile() && new File(child, "src/main/webapp").isDirectory()) {
                    return child;
                }
            }
        }
        throw new IllegalStateException("Could not locate 01-Login-Signup-Home project. Open the folder containing pom.xml in IntelliJ IDEA.");
    }
}
