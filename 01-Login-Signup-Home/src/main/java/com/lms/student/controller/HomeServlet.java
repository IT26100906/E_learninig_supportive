package com.lms.student.controller;

import com.lms.student.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"", "/home"})
public class HomeServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);
        if (u != null) {
            redirect(req, res, u.getHomePath());   // polymorphism: student -> /dashboard, admin -> /admin/dashboard
            return;
        }
        render(req, res, "home");
    }
}
