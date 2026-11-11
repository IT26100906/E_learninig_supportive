package com.lms.student.controller;

import com.lms.student.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Student dashboard: Child / School / A-L / Undergraduate each get a different page. */
@WebServlet("/dashboard")
public class DashboardServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);
        if (u.canManageUsers()) { redirect(req, res, u.getHomePath()); return; }
        // each learner level has its own dashboard page (and its own theme in the header)
        req.setAttribute("greeting", u.getLevel().greeting(u.getName()));
        req.setAttribute("subjects", u.getLevel().subjects(u.getLevelDetail()));
        req.setAttribute("highlight", u.getLevel().highlight(u.getLevelDetail()));
        render(req, res, u.getLevel().getDashboardView());
    }
}
