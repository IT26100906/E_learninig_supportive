package com.lms.student.servlet;

import com.lms.student.model.AccountStatus;
import com.lms.student.model.Page;
import com.lms.student.model.User;
import com.lms.student.util.AppConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * READ (search / sort / filter / paginate) and DELETE / activate / deactivate students.
 * Delete and status changes are POST requests (never a plain link).
 */
@WebServlet("/admin/students")
public class AdminStudentsServlet extends BaseServlet {

    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String q = param(req, "q");
        String status = param(req, "status");
        String sort = param(req, "sort");
        String level = param(req, "level");
        int page = 1;
        try { page = Integer.parseInt(param(req, "page")); } catch (NumberFormatException ignored) { }

        Page<User> result = userService.search(q, status, level, sort, page, PAGE_SIZE);
        req.setAttribute("result", result);
        req.setAttribute("q", q);
        req.setAttribute("status", status.isEmpty() ? "ALL" : status);
        req.setAttribute("sort", sort.isEmpty() ? "id" : sort);
        req.setAttribute("level", level.isEmpty() ? "ALL" : level);
        // query string reused by the pagination links
        req.setAttribute("qs", "q=" + URLEncoder.encode(q, StandardCharsets.UTF_8)
                + "&status=" + URLEncoder.encode(status, StandardCharsets.UTF_8)
                + "&level=" + URLEncoder.encode(level, StandardCharsets.UTF_8)
                + "&sort=" + URLEncoder.encode(sort, StandardCharsets.UTF_8));
        render(req, res, "admin/students");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = param(req, "action");
        String id = param(req, "id");
        User target = userService.findById(id).orElse(null);

        if (target == null || target.canManageUsers()) {
            flash(req, "danger", "Student not found.");
        } else if ("delete".equals(action)) {
            userService.delete(id);
            if (target.getProfilePicture() != null && !target.getProfilePicture().isBlank())
                new File(AppConfig.photoDir(), new File(target.getProfilePicture()).getName()).delete();
            flash(req, "success", "Student " + id + " was deleted.");
        } else if ("activate".equals(action)) {
            userService.setStatus(id, AccountStatus.ACTIVE);
            flash(req, "success", "Student " + id + " is now active.");
        } else if ("deactivate".equals(action)) {
            userService.setStatus(id, AccountStatus.INACTIVE);
            flash(req, "warning", "Student " + id + " was deactivated.");
        }
        String back = param(req, "back");
        redirect(req, res, back.startsWith("?") ? "/admin/students" + back : "/admin/students");
    }
}
