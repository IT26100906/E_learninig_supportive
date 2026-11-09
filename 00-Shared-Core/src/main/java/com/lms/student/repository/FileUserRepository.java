package com.lms.student.repository;

import com.lms.student.model.User;
import com.lms.student.model.UserFactory;
import com.lms.student.util.AppConfig;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Stores users in data/users.txt (one user per line, fields separated by '|').
 *
 * File handling notes:
 *  - Every method is synchronized so two requests cannot write the file at the same time.
 *  - Writes go to a temporary file first and then replace users.txt (so the data file is
 *    never left half-written if something fails).
 */
public class FileUserRepository implements UserRepository {

    private static final String HEADER =
        "# type|id|name|email|passwordHash|phone|dob|address|status|regDate|lastLogin|photo|secQuestion|secAnswerHash|level|levelDetail";

    private static final FileUserRepository INSTANCE = new FileUserRepository();

    public static FileUserRepository getInstance() { return INSTANCE; }

    private FileUserRepository() { }

    @Override
    public synchronized List<User> findAll() {
        List<User> users = new ArrayList<>();
        Path file = AppConfig.usersFile().toPath();
        if (!Files.exists(file)) return users;
        try {
            for (String line : Files.readAllLines(file, StandardCharsets.UTF_8)) {
                User u = UserFactory.fromFileLine(line);
                if (u != null) users.add(u);
            }
        } catch (IOException e) {
            throw new UncheckedIOException("Cannot read users.txt", e);
        }
        return users;
    }

    @Override
    public synchronized Optional<User> findById(String id) {
        if (id == null) return Optional.empty();
        return findAll().stream().filter(u -> u.getId().equalsIgnoreCase(id.trim())).findFirst();
    }

    @Override
    public synchronized Optional<User> findByEmail(String email) {
        if (email == null) return Optional.empty();
        return findAll().stream().filter(u -> u.getEmail().equalsIgnoreCase(email.trim())).findFirst();
    }

    @Override
    public synchronized void create(User user) {
        List<User> users = findAll();
        users.add(user);
        writeAll(users);
    }

    @Override
    public synchronized void update(User user) {
        List<User> users = findAll();
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId().equalsIgnoreCase(user.getId())) {
                users.set(i, user);
            }
        }
        writeAll(users);
    }

    @Override
    public synchronized boolean delete(String id) {
        List<User> users = findAll();
        boolean removed = users.removeIf(u -> u.getId().equalsIgnoreCase(id));
        if (removed) writeAll(users);
        return removed;
    }

    private void writeAll(List<User> users) {
        Path file = AppConfig.usersFile().toPath();
        Path temp = file.resolveSibling("users.txt.tmp");
        List<String> lines = new ArrayList<>();
        lines.add(HEADER);
        for (User u : users) lines.add(u.toFileLine());
        try {
            Files.write(temp, lines, StandardCharsets.UTF_8);
            Files.move(temp, file, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new UncheckedIOException("Cannot write users.txt", e);
        }
    }
}
