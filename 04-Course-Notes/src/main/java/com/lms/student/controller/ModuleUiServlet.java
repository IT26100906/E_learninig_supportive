package com.lms.student.controller;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
/** Course Notes only; JSP contains both student and admin controls. */
@WebServlet("/course-notes")
public class ModuleUiServlet extends BaseServlet {
 @Override protected void doGet(HttpServletRequest req,HttpServletResponse res) throws ServletException,IOException {
   render(req,res,"modules/course-notes");
 }
}
