package com.lms.student.servlet;

import com.lms.student.model.User;
import com.lms.student.service.AuthException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    private static final String REMEMBER_COOKIE = "lh_user";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);
        if (u != null) { redirect(req, res, u.getHomePath()); return; }
        showForm(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        try {
            User user = userService.login(param(req, "idOrEmail"), req.getParameter("password"));
            // new session id after login (prevents session fixation)
            req.getSession(true);
            req.changeSessionId();
            req.getSession().setAttribute("userId", user.getId());

            // "Remember me" only remembers the Student ID (never the password) for 30 days
            Cookie c = new Cookie(REMEMBER_COOKIE, URLEncoder.encode(user.getId(), StandardCharsets.UTF_8));
            c.setHttpOnly(true);
            c.setPath(req.getContextPath().isEmpty() ? "/" : req.getContextPath());
            c.setMaxAge(req.getParameter("remember") != null ? 30 * 24 * 3600 : 0);
            res.addCookie(c);

            flash(req, "success", "Welcome back, " + user.getName() + "!");
            redirect(req, res, user.getHomePath());
        } catch (AuthException e) {
            req.setAttribute("errors", java.util.List.of(e.getMessage()));
            showForm(req, res);
        }
    }

    private void showForm(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        if (req.getCookies() != null) {
            for (Cookie c : req.getCookies()) {
                if (REMEMBER_COOKIE.equals(c.getName())) {
                    req.setAttribute("rememberedUser", URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8));
                }
            }
        }
        render(req, res, "login");
    }
}
