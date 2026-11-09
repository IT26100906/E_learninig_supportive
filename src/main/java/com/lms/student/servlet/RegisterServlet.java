package com.lms.student.servlet;

import com.lms.student.model.User;
import com.lms.student.service.UserService;
import com.lms.student.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** CREATE - public student registration. */
@WebServlet("/register")
public class RegisterServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);
        if (u != null) { redirect(req, res, u.getHomePath()); return; }
        req.setAttribute("questions", UserService.SECURITY_QUESTIONS);
        preparePicker(req, "", "");
        render(req, res, "register");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            User created = userService.register(
                "", param(req, "name"), param(req, "email"),
                req.getParameter("password"), req.getParameter("confirmPassword"),
                param(req, "phone"), param(req, "dob"), param(req, "address"),
                param(req, "question"), param(req, "answer"), false,
                param(req, "level"), pickerDetail(req, param(req, "level")));
            flash(req, "success", "Registration successful! Your Student ID is " + created.getId() + " - you can sign in with it or your email.");
            redirect(req, res, "/login");
        } catch (ValidationException e) {
            req.setAttribute("errors", e.getErrors());
            req.setAttribute("questions", UserService.SECURITY_QUESTIONS);
            preparePicker(req, param(req, "level"), pickerDetail(req, param(req, "level")));
            render(req, res, "register");
        }
    }
}
