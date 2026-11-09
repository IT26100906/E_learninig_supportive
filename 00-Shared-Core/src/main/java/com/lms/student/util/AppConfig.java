package com.lms.student.util;

import java.io.File;
import java.io.IOException;

/** Central place for file locations (profile pictures, and the old users.txt used only for the one-time import). Change the folder with -Dlms.data.dir=/some/path */
public final class AppConfig {

    private AppConfig() { }

    public static File dataDir() {
        File dir = new File(System.getProperty("lms.data.dir", "data"));
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }

    public static File usersFile() {
        return new File(dataDir(), "users.txt");
    }

    public static File photoDir() {
        File dir = new File(dataDir(), "profile-pics");
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }

    /** Makes sure the data folders exist (users are stored in the database, photos stay as files). */
    public static void ensureFiles() throws IOException {
        dataDir();
        photoDir();
    }
}
