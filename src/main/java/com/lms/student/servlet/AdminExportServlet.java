package com.lms.student.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/** Download all students as a CSV file (opens in Excel). */
@WebServlet("/admin/students/export")
public class AdminExportServlet extends BaseServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        res.setContentType("text/csv");
        res.setCharacterEncoding("UTF-8");
        res.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");
        res.getOutputStream().write(new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF}); // BOM for Excel
        res.getOutputStream().write(userService.exportCsv().getBytes(StandardCharsets.UTF_8));
    }
}
