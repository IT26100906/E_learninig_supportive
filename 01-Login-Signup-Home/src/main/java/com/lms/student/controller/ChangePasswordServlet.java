package com.lms.student.controller;

import com.lms.student.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/change-password")
public class ChangePasswordServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        render(req, res, "change-password");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            userService.changePassword(currentUser(req), req.getParameter("oldPassword"),
                    req.getParameter("newPassword"), req.getParameter("confirmPassword"));
            flash(req, "success", "Password changed successfully.");
            redirect(req, res, "/profile");
        } catch (ValidationException e) {
            req.setAttribute("errors", e.getErrors());
            render(req, res, "change-password");
        }
    }
}
