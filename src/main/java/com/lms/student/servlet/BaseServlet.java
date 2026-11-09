package com.lms.student.servlet;

import com.lms.student.model.StudentLevel;
import com.lms.student.model.User;
import com.lms.student.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Parent of all servlets (INHERITANCE). Holds the shared helper methods so the
 * child servlets stay short and readable.
 */
public abstract class BaseServlet extends HttpServlet {

    protected final UserService userService = new UserService();

    /** The logged-in user (set by AuthFilter), or null. */
    protected User currentUser(HttpServletRequest req) {
        return (User) req.getAttribute("currentUser");
    }

    /** Trimmed request parameter (empty string if missing). */
    protected String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return v == null ? "" : v.trim();
    }

    /** Forwards to /WEB-INF/views/{view}.jsp and moves any flash message to the request. */
    protected void render(HttpServletRequest req, HttpServletResponse res, String view)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("flashMessage") != null) {
            req.setAttribute("flashType", session.getAttribute("flashType"));
            req.setAttribute("flashMessage", session.getAttribute("flashMessage"));
            session.removeAttribute("flashType");
            session.removeAttribute("flashMessage");
        }
        req.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(req, res);
    }

    /** Stores a message that is shown on the NEXT page (after a redirect). */
    protected void flash(HttpServletRequest req, String type, String message) {
        HttpSession session = req.getSession(true);
        session.setAttribute("flashType", type);
        session.setAttribute("flashMessage", message);
    }

    /** The level picker has one detail input per level; this returns the one for the chosen level. */
    protected String pickerDetail(HttpServletRequest req, String level) {
        switch (level == null ? "" : level) {
            case "CHILD":  return param(req, "detailChild");
            case "SCHOOL": return param(req, "detailSchool");
            case "AL":     return param(req, "detailAl");
            default:       return param(req, "detailUni");
        }
    }

    /** Values needed by common/level-picker.jsp. */
    protected void preparePicker(HttpServletRequest req, String level, String detail) {
        req.setAttribute("selLevel", level == null ? "" : level);
        req.setAttribute("selDetail", detail == null ? "" : detail);
        req.setAttribute("streams", StudentLevel.AL_STREAMS);
        req.setAttribute("degrees", StudentLevel.UG_DEGREES);
        // an old free-text degree (not in the list) is kept as an extra option so editing does not lose it
        req.setAttribute("degreeExtra", "UNDERGRAD".equals(level) && detail != null && !detail.isBlank()
                && !StudentLevel.isKnownDegree(detail) ? detail : "");
    }

    protected void redirect(HttpServletRequest req, HttpServletResponse res, String path) throws IOException {
        res.sendRedirect(req.getContextPath() + path);
    }
}
