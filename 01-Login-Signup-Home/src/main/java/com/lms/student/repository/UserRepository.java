package com.lms.student.repository;

import com.lms.student.model.User;

import java.util.List;
import java.util.Optional;

/**
 * Abstraction over where users are stored. The service layer only depends on this
 * interface, so the text file could later be replaced by a database without
 * changing any other code.
 */
public interface UserRepository {
    List<User> findAll();                       // READ all
    Optional<User> findById(String id);         // READ one
    Optional<User> findByEmail(String email);   // READ one
    void create(User user);                     // CREATE
    void update(User user);                     // UPDATE
    boolean delete(String id);                  // DELETE
}
