package com.lms.student.controller;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.lms.student.model.User;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * UI pages for six modules: Course Details, Course Feedback / Reviews, Course Notes / Study Materials,
 * Course Enrollment, Assignment and Payment.
 * Each URL simply opens its JSP (views/modules/*.jsp). The pages use sample data in the browser,
 * so the real back-end (servlets + database) can be connected later without changing the look.
 * Login is required (AuthFilter protects every URL that is not public).
 *
 * Admins get their own management pages for Course Enrollment, Assignments and Payment (views/modules/admin-*.jsp):
 * enrollments, assignments + submissions + marks and payments of all students, split by learner level.
 */
@WebServlet("/assignments")
public class ModuleUiServlet extends BaseServlet {

    private static final Map<String, String> VIEWS = Map.of("/assignments", "modules/assignments");

    /** Pages that look different for an admin. */
    private static final Map<String, String> ADMIN_VIEWS = Map.of("/assignments", "modules/admin-assignments");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String path = req.getServletPath();
        User me = currentUser(req);
        if (me != null && me.canManageUsers() && ADMIN_VIEWS.containsKey(path)) {
            // the admin pages list real students (from the database) so every enrollment / payment belongs to a real student ID
            List<User> roster = userService.findAll().stream()
                    .filter(u -> !u.canManageUsers())
                    .sorted((a, b) -> a.getId().compareToIgnoreCase(b.getId()))
                    .collect(Collectors.toList());
            req.setAttribute("roster", roster);
            render(req, res, ADMIN_VIEWS.get(path));
            return;
        }
        render(req, res, VIEWS.get(path));
    }
}
