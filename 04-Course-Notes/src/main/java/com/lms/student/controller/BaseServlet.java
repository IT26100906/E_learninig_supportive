package com.lms.student.controller;
import com.lms.student.model.User;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Common servlet methods for Course Notes only. */
public abstract class BaseServlet extends HttpServlet {
  protected User currentUser(HttpServletRequest req) { return (User) req.getAttribute("currentUser"); }
  protected String param(HttpServletRequest req,String name) { String v=req.getParameter(name); return v == null ? "" : v.trim(); }
  protected void render(HttpServletRequest req,HttpServletResponse res,String view) throws ServletException,IOException {
    req.getRequestDispatcher("/WEB-INF/views/"+view+".jsp").forward(req,res);
  }
}
