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

        Context ctx = tomcat.addWebapp("", webapp.getAbsolutePath());

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
        File here = new File(".").getAbsoluteFile().getParentFile();
        File[] candidates = {
            here,
            new File(here, "StudentApp"),
            here.getParentFile(),
            here.getParentFile() == null ? null : new File(here.getParentFile(), "StudentApp")
        };
        for (File c : candidates) {
            if (c != null && new File(c, "pom.xml").exists() && new File(c, "src/main/webapp").exists()) {
                return c;
            }
        }
        throw new IllegalStateException(
            "Cannot find the StudentApp project folder (the one with pom.xml). Started from: " + here);
    }
}
