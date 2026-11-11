package com.lms.student.config;

import com.lms.student.model.Admin;
import com.lms.student.model.Student;
import com.lms.student.model.User;
import com.lms.student.model.StudentLevel;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

/** LOCAL-ONLY MEMBER PREVIEW. Replace with real authentication before deployment. */
@WebFilter("/*")
public class DemoModeFilter implements Filter {
  @Override public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
    HttpServletRequest req = (HttpServletRequest)request;
    HttpServletResponse res = (HttpServletResponse)response;
    req.setCharacterEncoding("UTF-8");
    String role = (String)req.getSession(true).getAttribute("demoRole");
    if (role == null) role = "student";
    User user;
    if ("admin".equals(role)) user = new Admin("DEMOADMIN", "Demo Administrator", "preview-admin@example.invalid", "");
    else {
      Student student = new Student("DEMOSTUDENT", "Demo Student", "preview-student@example.invalid", "");
      student.setLevel(StudentLevel.UNDERGRAD);
      user = student;
    }
    req.setAttribute("currentUser",user);
    res.setHeader("Cache-Control","no-store");
    chain.doFilter(req,res);
  }
}
