package com.lms.student.controller;

import com.lms.student.model.User;
import com.lms.student.service.UserService;
import com.lms.student.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Admin: add a new student (CREATE) or edit an existing one (UPDATE).
 *   /admin/students/form          -> blank form
 *   /admin/students/form?id=S001  -> edit form
 */
@WebServlet("/admin/students/form")
public class AdminStudentFormServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String id = param(req, "id");
        if (!id.isEmpty()) {
            User s = userService.findById(id).orElse(null);
            if (s == null || s.canManageUsers()) {
                flash(req, "danger", "Student not found.");
                redirect(req, res, "/admin/students");
                return;
            }
            req.setAttribute("student", s);
            preparePicker(req, s.getLevel().name(), s.getLevelDetail());
        } else {
            preparePicker(req, "", "");
        }
        req.setAttribute("questions", UserService.SECURITY_QUESTIONS);
        render(req, res, "admin/student-form");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        boolean editing = "edit".equals(param(req, "mode"));
        boolean premium = "PREMIUM".equals(param(req, "membership"));
        String id = param(req, "id");
        try {
            if (editing) {
                userService.adminUpdate(id, param(req, "name"), param(req, "email"), param(req, "phone"),
                        param(req, "dob"), param(req, "address"), param(req, "status"), premium,
                        param(req, "level"), pickerDetail(req, param(req, "level")));
                String newPw = req.getParameter("newPassword");
                if (newPw != null && !newPw.isBlank()) userService.adminResetPassword(id, newPw);
                flash(req, "success", "Student " + id + " updated successfully.");
            } else {
                userService.register(id, param(req, "name"), param(req, "email"),
                        req.getParameter("password"), req.getParameter("password"),
                        param(req, "phone"), param(req, "dob"), param(req, "address"),
                        param(req, "question"), param(req, "answer"), premium,
                        param(req, "level"), pickerDetail(req, param(req, "level")));
                flash(req, "success", "Student " + id + " added successfully.");
            }
            redirect(req, res, "/admin/students");
        } catch (ValidationException e) {
            req.setAttribute("errors", e.getErrors());
            req.setAttribute("questions", UserService.SECURITY_QUESTIONS);
            preparePicker(req, param(req, "level"), pickerDetail(req, param(req, "level")));
            if (editing) userService.findById(id).ifPresent(s -> req.setAttribute("student", s));
            render(req, res, "admin/student-form");
        }
    }
}
