package com.lms.student.service;
import com.lms.student.controller.BaseServlet;

import com.lms.student.model.User;
import com.lms.student.repository.AppDataRepository;
import com.lms.student.repository.DataMirror;
import com.lms.student.util.Json;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

/**
 * Database storage for the module pages (table app_data).
 *
 *  GET  /js/store.js                : JavaScript that puts the logged-in user's saved data into  window.LH_STORE
 *                                     (loaded before modules.js, so LH.load() can read it at once).
 *  POST /store  key, value          : saves one value (JSON text) for the logged-in user (or the shared value for shared keys).
 *  POST /store  action=delete, key  : removes one value.
 *  POST /store  action=reset        : removes all private values of the logged-in user (marks given by the admin stay).
 *
 * Assignments:  shared key adm-asg = the assignments the admin created (per learner level);
 *               asg-s-<id>  (private) = a student's submission;  asg-g-<id> (private, written ONLY by an admin) = the marks.
 *  GET  /store?action=submissions          : (admin) all students' submissions + marks
 *  POST /store  action=grade, owner, aid, score, max, feedback : (admin) give / change marks
 *
 * Shared keys are visible to everybody; only admins may change them, except "reviews" (students post reviews).
 */

public class CourseEnrollmentStoreService extends BaseServlet {

    /** Keys stored once for the whole site (owner "*"). */
    private static final Set<String> SHARED_KEYS = Set.of("courses-overlay", "reviews", "adm-enr", "adm-pay", "adm-seen", "adm-asg");
    /** Shared keys that students may also write. */
    private static final Set<String> STUDENT_WRITABLE = Set.of("reviews");
    private static final Pattern KEY = Pattern.compile("[a-z0-9-]{1,40}");
    private static final int MAX_VALUE = 1_500_000;

    private final AppDataRepository repo = AppDataRepository.getInstance();
    private final DataMirror mirror = DataMirror.getInstance();   // keeps the readable tables (courses, enrollments ...) up to date

    /** Assignment keys: asg-s-<id> = a student's submission (student writes), asg-g-<id> = the marks (ONLY an admin writes). */
    private static final String SUBMISSION = "asg-s-", GRADE = "asg-g-";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        if ("submissions".equals(param(req, "action"))) { submissions(req, res); return; }
        res.setContentType("application/javascript;charset=UTF-8");
        res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        res.setHeader("Pragma", "no-cache");
        User me = currentUser(req);
        StringBuilder sb = new StringBuilder("window.LH_STORE={ctx:").append(js(req.getContextPath())).append(",u:{");
        if (me != null) {
            append(sb, repo.findByOwner(me.getId()));
            sb.append("},s:{");
            append(sb, repo.findByOwner(AppDataRepository.SHARED));
        } else {
            sb.append("},s:{");
        }
        sb.append("}};");
        res.getWriter().write(sb.toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        User me = currentUser(req);
        if (me == null) { json(res, 401, "{\"error\":\"Please log in\"}"); return; }

        String action = param(req, "action");
        if ("reset".equals(action)) {
            for (String k : repo.findByOwner(me.getId()).keySet()) if (!k.startsWith(GRADE)) repo.delete(me.getId(), k);   // marks given by the admin stay
            mirror.removeOwner(me.getId());
            mirror.refreshAssignments();
            json(res, 200, "{\"ok\":true}");
            return;
        }
        if ("grade".equals(action)) { grade(req, res, me); return; }
        String key = param(req, "key");
        if (!KEY.matcher(key).matches()) { json(res, 400, "{\"error\":\"Bad key\"}"); return; }
        // marks can only be written through action=grade by an admin (a student must never be able to give himself marks)
        if (key.startsWith(GRADE)) { json(res, 403, "{\"error\":\"Only the admin can give marks\"}"); return; }

        boolean shared = SHARED_KEYS.contains(key);
        if (shared && !me.canManageUsers() && !STUDENT_WRITABLE.contains(key)) {
            json(res, 403, "{\"error\":\"Admins only\"}");
            return;
        }
        String owner = shared ? AppDataRepository.SHARED : me.getId();

        if ("delete".equals(action)) {
            repo.delete(owner, key);
            mirror.remove(owner, key);
            json(res, 200, "{\"ok\":true}");
            return;
        }
        String value = req.getParameter("value");
        if (value == null || value.isEmpty() || value.length() > MAX_VALUE) {
            json(res, 400, "{\"error\":\"Bad value\"}");
            return;
        }
        if (key.startsWith(SUBMISSION) && (!key.substring(SUBMISSION.length()).matches("[0-9]{1,12}") || !(Json.parse(value) instanceof Map))) {
            json(res, 400, "{\"error\":\"Bad submission\"}");
            return;
        }
        repo.put(owner, key, value);
        mirror.apply(owner, key, value);
        json(res, 200, "{\"ok\":true}");
    }

    /** ADMIN: every student's submissions and marks, as JSON {"sub":{studentId:{key:value}},"grade":{...}} (values stay JSON strings). */
    private void submissions(HttpServletRequest req, HttpServletResponse res) throws IOException {
        User me = currentUser(req);
        if (me == null || !me.canManageUsers()) { json(res, 403, "{\"error\":\"Admins only\"}"); return; }
        res.setHeader("Cache-Control", "no-store");
        StringBuilder sb = new StringBuilder("{\"sub\":");
        appendByOwner(sb, repo.findByKeyPrefix(SUBMISSION));
        sb.append(",\"grade\":");
        appendByOwner(sb, repo.findByKeyPrefix(GRADE));
        json(res, 200, sb.append('}').toString());
    }

    private static void appendByOwner(StringBuilder sb, java.util.List<String[]> rows) {
        Map<String, StringBuilder> by = new java.util.LinkedHashMap<>();
        for (String[] r : rows) {
            StringBuilder b = by.computeIfAbsent(r[0], k -> new StringBuilder());
            if (b.length() > 0) b.append(',');
            if (Json.parse(r[2]) == null) continue;   // never copy damaged text into the answer
            b.append(jsonStr(r[1])).append(':').append(r[2]);
        }
        sb.append('{');
        boolean first = true;
        for (Map.Entry<String, StringBuilder> e : by.entrySet()) {
            if (!first) sb.append(',');
            first = false;
            sb.append(jsonStr(e.getKey())).append(":{").append(e.getValue()).append('}');
        }
        sb.append('}');
    }

    /** ADMIN: POST action=grade, owner=<student id>, aid=<assignment id>, score, max, feedback  -> saved as the student's key asg-g-<aid>. */
    private void grade(HttpServletRequest req, HttpServletResponse res, User me) throws IOException {
        if (!me.canManageUsers()) { json(res, 403, "{\"error\":\"Admins only\"}"); return; }
        String owner = param(req, "owner"), aid = param(req, "aid");
        if (!owner.matches("[A-Za-z0-9_-]{1,12}") || !aid.matches("[0-9]{1,12}")) { json(res, 400, "{\"error\":\"Bad student or assignment\"}"); return; }
        // the student must really have submitted this assignment
        if (!repo.findByOwner(owner).containsKey(SUBMISSION + aid)) { json(res, 400, "{\"error\":\"This student has not submitted this assignment\"}"); return; }
        double score, max;
        try { score = Double.parseDouble(param(req, "score")); max = Double.parseDouble(param(req, "max")); }
        catch (NumberFormatException e) { json(res, 400, "{\"error\":\"Marks must be a number\"}"); return; }
        if (Double.isNaN(score) || score < 0 || max <= 0 || score > max) { json(res, 400, "{\"error\":\"Marks must be between 0 and " + (long) max + "\"}"); return; }
        String feedback = param(req, "feedback");
        if (feedback.length() > 500) feedback = feedback.substring(0, 500);
        String value = "{\"score\":" + (score == Math.rint(score) ? String.valueOf((long) score) : String.valueOf(score))
                + ",\"feedback\":" + jsonStr(feedback) + ",\"by\":" + jsonStr(me.getId())
                + ",\"on\":" + jsonStr(java.time.LocalDate.now().toString()) + "}";
        repo.put(owner, GRADE + aid, value);
        mirror.apply(owner, GRADE + aid, value);
        json(res, 200, "{\"ok\":true}");
    }

    /** Plain JSON string literal. */
    private static String jsonStr(String s) {
        StringBuilder sb = new StringBuilder("\"");
        for (char c : (s == null ? "" : s).toCharArray()) {
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default: if (c < 0x20) sb.append(' '); else sb.append(c);
            }
        }
        return sb.append('"').toString();
    }

    private static void append(StringBuilder sb, Map<String, String> m) {
        boolean first = true;
        for (Map.Entry<String, String> e : m.entrySet()) {
            if (!first) sb.append(',');
            first = false;
            sb.append(js(e.getKey())).append(':').append(js(e.getValue()));   // value stays a JSON *string*; the browser parses it
        }
    }

    /** JavaScript string literal (safe inside a script file). */
    private static String js(String s) {
        StringBuilder sb = new StringBuilder("\"");
        for (char c : (s == null ? "" : s).toCharArray()) {
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '<':  sb.append("\\u003c"); break;
                case ' ': sb.append("\\u2028"); break;
                case ' ': sb.append("\\u2029"); break;
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
