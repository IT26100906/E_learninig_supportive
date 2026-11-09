package com.lms.student.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Course Details page.
 * One servlet per page, so every part can be run alone AND merged with the other parts without a clash.
 * loadOnStartup=1 + the context attribute "mod.details" tell the sidebar (common/header.jsp) that this module is installed.
 */
@WebServlet(urlPatterns = "/course-details", loadOnStartup = 1)
public class CourseDetailsServlet extends BaseServlet {

    @Override
    public void init() throws ServletException {
        super.init();
        getServletContext().setAttribute("mod.details", Boolean.TRUE);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        render(req, res, "modules/course-details");
    }
}
