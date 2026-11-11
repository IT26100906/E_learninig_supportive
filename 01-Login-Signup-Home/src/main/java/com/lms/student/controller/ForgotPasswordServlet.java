package com.lms.student.controller;

import com.lms.student.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/** Forgot password: step 1 = enter ID, step 2 = answer the security question + new password. */
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        render(req, res, "forgot-password");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String step = param(req, "step");
        String id = param(req, "id");
        try {
            if ("lookup".equals(step)) {
                String question = userService.getSecurityQuestion(id);
                req.setAttribute("question", question);
                req.setAttribute("studentId", id);
                render(req, res, "forgot-password");
            } else {
                userService.resetPassword(id, param(req, "answer"),
                        req.getParameter("newPassword"), req.getParameter("confirmPassword"));
                flash(req, "success", "Password reset successfully. Please log in with your new password.");
                redirect(req, res, "/login");
            }
        } catch (ValidationException e) {
            req.setAttribute("errors", e.getErrors());
            if ("reset".equals(step)) {
                try {
                    req.setAttribute("question", userService.getSecurityQuestion(id));
                    req.setAttribute("studentId", id);
                } catch (ValidationException ignored) { /* shows step 1 again */ }
            }
            render(req, res, "forgot-password");
        }
    }
}
