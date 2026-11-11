package com.lms.student.controller;

import com.lms.student.model.StudentLevel;
import com.lms.student.model.User;
import com.lms.student.service.ValidationException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** READ (/profile) and UPDATE (/profile/edit) of the logged-in user's own details. */
@WebServlet(urlPatterns = {"/profile", "/profile/edit"})
public class ProfileServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        boolean edit = req.getServletPath().equals("/profile/edit");
        req.setAttribute("streams", StudentLevel.AL_STREAMS);
        render(req, res, edit ? "edit-profile" : "profile");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);
        try {
            userService.updateProfile(u, param(req, "name"), param(req, "email"),
                    param(req, "phone"), param(req, "dob"), param(req, "address"), param(req, "levelDetail"));
            flash(req, "success", "Profile updated successfully.");
            redirect(req, res, "/profile");
        } catch (ValidationException e) {
            req.setAttribute("errors", e.getErrors());
            req.setAttribute("streams", StudentLevel.AL_STREAMS);
            render(req, res, "edit-profile");
        }
    }
}
