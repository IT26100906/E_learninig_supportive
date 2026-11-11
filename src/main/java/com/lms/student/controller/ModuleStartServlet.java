package com.lms.student.controller;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/** Starts directly on this member's own module; role switch is for LOCAL DEMO ONLY. */
@WebServlet(urlPatterns={"", "/home", "/demo-role"})
public class ModuleStartServlet extends HttpServlet {
  @Override protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
    if ("/demo-role".equals(req.getServletPath())) {
      String role=req.getParameter("role");
      if ("admin".equals(role) || "student".equals(role)) req.getSession(true).setAttribute("demoRole",role);
    }
    res.sendRedirect(req.getContextPath()+"/assignments");
    res.sendRedirect(req.getContextPath()+"/course-feedback");
    res.sendRedirect(req.getContextPath()+"/course-details");
  }
}
