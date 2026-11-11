package com.lms.student.config;

import com.lms.student.model.User;
import com.lms.student.repository.JdbcUserRepository;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Optional;

/**
 * Runs before every request.
 *  1. Sets UTF-8 encoding.
 *  2. Loads the logged-in user (fresh from the database) into request attribute "currentUser".
 *  3. Redirects to /login when a protected page is opened without logging in.
 *  4. Blocks /admin/* for users who are not admins (polymorphism: user.canManageUsers()).
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");

        String path = req.getRequestURI().substring(req.getContextPath().length());

        // Load current user (if any)
        HttpSession session = req.getSession(false);
        User user = null;
        if (session != null && session.getAttribute("userId") != null) {
            Optional<User> found = JdbcUserRepository.getInstance().findById((String) session.getAttribute("userId"));
            if (found.isPresent() && found.get().isActive()) {
                user = found.get();
                req.setAttribute("currentUser", user);
            } else {
                session.invalidate(); // deleted or deactivated while logged in
            }
        }

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        if (user == null) {
            req.getSession(true).setAttribute("flashType", "warning");
            req.getSession().setAttribute("flashMessage", "Please log in to continue.");
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (path.startsWith("/admin") && !user.canManageUsers()) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Admins only");
            return;
        }

        // Do not let the browser cache pages that contain personal data
        res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        return path.isEmpty() || path.equals("/") || path.equals("/home")
            || path.equals("/login") || path.equals("/logout")
            || path.equals("/register") || path.equals("/forgot-password")
            || path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/")
            || path.equals("/favicon.ico")
            || path.equals("/store");   // StoreServlet checks the login itself and answers 401 JSON
    }
}
