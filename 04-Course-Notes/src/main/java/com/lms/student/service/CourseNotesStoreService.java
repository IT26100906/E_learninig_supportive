package com.lms.student.service;

import com.lms.student.controller.BaseServlet;
import com.lms.student.model.User;
import com.lms.student.repository.AppDataRepository;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Map;
import java.util.Set;

/** Only the Course Notes module's personal notes and saved-list state. */
public class CourseNotesStoreService extends BaseServlet {
    private final AppDataRepository repo = AppDataRepository.getInstance();
    private static final Set<String> KEYS = Set.of("notes", "notes-saved");

    @Override protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/javascript;charset=UTF-8");
        res.setHeader("Cache-Control", "no-store");
        User me = currentUser(req);
        StringBuilder js = new StringBuilder("window.LH_STORE={ctx:").append(quote(req.getContextPath())).append(",u:{");
        if (me != null) {
            boolean first = true;
            for (Map.Entry<String,String> row : repo.findByOwner(me.getId()).entrySet()) {
                if (!KEYS.contains(row.getKey())) continue;
                if (!first) js.append(',');
                js.append(quote(row.getKey())).append(':').append(quote(row.getValue()));
                first = false;
            }
        }
        js.append("},s:{}};");
        res.getWriter().print(js);
    }

    @Override protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        User me = currentUser(req);
        if (me == null) { res.setStatus(401); res.getWriter().print("{\"error\":\"Login required\"}"); return; }
        String key = param(req,"key");
        if (!KEYS.contains(key)) { res.setStatus(400); res.getWriter().print("{\"error\":\"Not a notes key\"}"); return; }
        String action = param(req,"action");
        if ("delete".equals(action)) repo.delete(me.getId(),key);
        else {
            String value = req.getParameter("value");
            if (value == null || value.isBlank() || value.length() > 1500000 || !value.trim().matches("(?s)\\[.*\\]")) {
                res.setStatus(400); res.getWriter().print("{\"error\":\"Invalid notes data\"}"); return;
            }
            repo.put(me.getId(),key,value);
        }
        res.getWriter().print("{\"ok\":true}");
    }
    private static String quote(String s) { return "\""+s.replace("\\","\\\\").replace("\"","\\\"")+"\""; }
}
