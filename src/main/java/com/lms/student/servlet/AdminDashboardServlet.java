package com.lms.student.servlet;

import com.lms.student.model.Page;
import com.lms.student.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/** Admin dashboard: statistics + the 5 newest students. (Access is checked by AuthFilter.) */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        req.setAttribute("stats", userService.statistics());
        Page<User> newest = userService.search("", "ALL", "newest", 1, 5);
        req.setAttribute("recent", newest.getItems());
        // all students: the page uses them to fill the enrollment / payment tables of the database (see syncAdminSeed)
        List<User> roster = userService.findAll().stream().filter(u -> !u.canManageUsers())
                .sorted((a, b) -> a.getId().compareToIgnoreCase(b.getId())).collect(Collectors.toList());
        req.setAttribute("roster", roster);
        render(req, res, "admin/dashboard");
    }
}
