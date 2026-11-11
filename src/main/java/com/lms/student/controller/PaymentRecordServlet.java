package com.lms.student.controller;

import com.lms.student.model.User;
import com.lms.student.repository.PaymentRepository;
import com.lms.student.repository.PaymentRepository.Payment;
import com.lms.student.service.ValidationException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;

/**
 * JSON endpoint used by the Payment pages.
 *  POST (student)            : saves the payment in the database; paying "Premium membership" upgrades the student to PREMIUM.
 *  GET  (admin)              : all payments of all students.
 *  POST action=delete (admin): removes one payment record.
 */
@WebServlet("/payment-records")
public class PaymentRecordServlet extends BaseServlet {

    private static final String PREMIUM = "Premium membership";
    private static final double PREMIUM_FEE = 1500;
    private static final Set<String> METHODS = Set.of("Card", "Bank transfer", "Online wallet");
    private final PaymentRepository repo = PaymentRepository.getInstance();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        User me = currentUser(req);
        if (me == null || !me.canManageUsers()) { json(res, 403, "{\"error\":\"Admins only\"}"); return; }
        List<Payment> all = repo.findAll();
        StringBuilder sb = new StringBuilder("{\"payments\":[");
        for (int i = 0; i < all.size(); i++) {
            Payment p = all.get(i);
            if (i > 0) sb.append(',');
            sb.append("{\"rcpt\":").append(q(p.rcpt)).append(",\"sid\":").append(q(p.studentId)).append(",\"course\":").append(q(p.course))
              .append(",\"desc\":").append(q(p.desc)).append(",\"amount\":").append(p.amount).append(",\"date\":").append(q(p.date))
              .append(",\"method\":").append(q(p.method)).append(",\"ref\":").append(q(p.ref)).append('}');
        }
        json(res, 200, sb.append("]}").toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        User me = currentUser(req);
        if (me == null) { json(res, 401, "{\"error\":\"Please log in\"}"); return; }

        if ("delete".equals(param(req, "action"))) {
            if (!me.canManageUsers()) { json(res, 403, "{\"error\":\"Admins only\"}"); return; }
            repo.delete(param(req, "rcpt"));
            json(res, 200, "{\"ok\":true}");
            return;
        }
        if (me.canManageUsers()) { json(res, 403, "{\"error\":\"Only students can pay\"}"); return; }

        String course = param(req, "course"), method = param(req, "method");
        double amount;
        try { amount = Double.parseDouble(param(req, "amount")); } catch (NumberFormatException e) { amount = -1; }
        if (course.isEmpty() || course.length() > 150 || amount <= 0 || !METHODS.contains(method)) {
            json(res, 400, "{\"error\":\"Invalid payment details\"}");
            return;
        }
        boolean premium = PREMIUM.equals(course);
        if (premium) amount = PREMIUM_FEE;              // the membership price is fixed on the server

        Payment p = new Payment();
        p.studentId = me.getId(); p.course = course; p.desc = cut(param(req, "desc"), 200); p.amount = amount;
        p.date = LocalDate.now().toString(); p.method = method; p.ref = cut(param(req, "ref"), 120);
        repo.add(p);

        boolean nowPremium = "PREMIUM".equals(me.getType());
        if (premium && !nowPremium) {
            try { userService.upgradeToPremium(me.getId()); nowPremium = true; }
            catch (ValidationException e) { /* student vanished: payment is still recorded */ }
        }
        json(res, 200, "{\"ok\":true,\"rcpt\":" + q(p.rcpt) + ",\"date\":" + q(p.date) + ",\"premium\":" + nowPremium + "}");
    }

    private static String cut(String s, int n) { return s.length() > n ? s.substring(0, n) : s; }

    private static String q(String s) {
        if (s == null) return "\"\"";
        StringBuilder sb = new StringBuilder("\"");
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': break;
                case '\t': sb.append("\\t"); break;
                default: if (c < 0x20) sb.append(' '); else sb.append(c);
            }
        }
        return sb.append('"').toString();
    }

    private void json(HttpServletResponse res, int status, String body) throws IOException {
        res.setStatus(status);
        res.setContentType("application/json;charset=UTF-8");
        res.getWriter().write(body);
    }
}
