package com.lms.student.service;

import com.lms.student.model.User;
import com.lms.student.controller.BaseServlet;
import com.lms.student.util.AppConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.regex.Pattern;

/**
 * File storage for Course Notes / Study Materials only.
 *
 *  POST /files   (multipart)  kind=material, file=...      -> uploads, answers JSON {"id","name","size"}
 *  POST /files   (material) title, course, lv, type, desc, url        -> also adds the material to the shared list (link type needs no file); lv = learner level (CHILD / SCHOOL / AL / UNDERGRAD)
 *  POST /files   action=delete, kind=..., id=... [entry=...]         -> deletes a stored file (and its material list entry)
 *  POST /files   action=update, kind=material, entry, title, course, lv, type, desc [, url] -> admin edits a material's details
 *  GET  /files?kind=material&list=1                                   -> JSON list of the uploaded study materials (shared by all students)
 *  GET  /files?kind=material&id=...&name=...&dl=1          -> shows (inline) or downloads (dl=1) the file
 *
 * Rules
 *  - material:   any logged-in user can read; only admins can upload / delete.
 *  - GET supports HTTP Range requests, so videos can be played and skipped through in the browser.
 *  - Only a safe list of file types is accepted, and stored under a random name (never the uploaded name).
 */

@MultipartConfig(maxFileSize = 200L * 1024 * 1024, maxRequestSize = 205L * 1024 * 1024)
public class CourseNotesService extends BaseServlet {

    private static final Map<String, String> TYPES = Map.ofEntries(
        Map.entry("pdf", "application/pdf"),
        Map.entry("doc", "application/msword"),
        Map.entry("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
        Map.entry("ppt", "application/vnd.ms-powerpoint"),
        Map.entry("pptx", "application/vnd.openxmlformats-officedocument.presentationml.presentation"),
        Map.entry("xls", "application/vnd.ms-excel"),
        Map.entry("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
        Map.entry("zip", "application/zip"),
        Map.entry("txt", "text/plain; charset=UTF-8"),
        Map.entry("py", "text/plain; charset=UTF-8"),
        Map.entry("java", "text/plain; charset=UTF-8"),
        Map.entry("csv", "text/plain; charset=UTF-8"),
        Map.entry("mp4", "video/mp4"),
        Map.entry("webm", "video/webm"),
        Map.entry("mp3", "audio/mpeg"),
        Map.entry("png", "image/png"),
        Map.entry("jpg", "image/jpeg"),
        Map.entry("jpeg", "image/jpeg"),
        Map.entry("gif", "image/gif"));

    /** Types the browser may show inside the page / tab. Everything else is always downloaded. */
    private static final Set<String> INLINE = Set.of("pdf", "txt", "py", "java", "csv", "mp4", "webm", "mp3", "png", "jpg", "jpeg", "gif");

    private static final Pattern STORED_ID = Pattern.compile("[a-f0-9]{32}\\.[a-z0-9]{2,5}");
    private static final Pattern SAFE_ID = Pattern.compile("[A-Za-z0-9_-]{1,40}");

    // ------------------------------------------------------------------ download / view
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User me = currentUser(req);
        String kind = param(req, "kind"), id = param(req, "id");
        if ("material".equals(kind) && "1".equals(param(req, "list"))) { listMaterials(res); return; }
        if (!"material".equals(kind)) { res.sendError(404); return; }
        if (!STORED_ID.matcher(id).matches()) { res.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        File dir = folderFor(kind, me, param(req, "uid"), false);
        if (dir == null) { res.sendError(HttpServletResponse.SC_FORBIDDEN); return; }
        File file = new File(dir, id);
        if (!file.isFile()) { res.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        String ext = id.substring(id.lastIndexOf('.') + 1);
        boolean download = "1".equals(param(req, "dl")) || !INLINE.contains(ext);
        String shown = safeName(param(req, "name"), "file." + ext, ext);

        res.setContentType(TYPES.getOrDefault(ext, "application/octet-stream"));
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setHeader("Content-Disposition", (download ? "attachment" : "inline") + "; filename=\"" + shown + "\"");
        res.setHeader("Accept-Ranges", "bytes");
        res.setHeader("Cache-Control", "private, max-age=0, must-revalidate");

        long length = file.length(), start = 0, end = length - 1;
        String range = req.getHeader("Range");
        if (range != null && range.startsWith("bytes=") && length > 0) {
            try {
                String[] p = range.substring(6).split(",")[0].trim().split("-", -1);
                if (p[0].isEmpty()) { start = Math.max(0, length - Long.parseLong(p[1])); }
                else { start = Long.parseLong(p[0]); if (!p[1].isEmpty()) end = Math.min(end, Long.parseLong(p[1])); }
                if (start > end || start >= length) {
                    res.setHeader("Content-Range", "bytes */" + length);
                    res.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
                    return;
                }
                res.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
                res.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + length);
            } catch (NumberFormatException | ArrayIndexOutOfBoundsException e) {
                start = 0; end = length - 1;   // bad Range header: send the whole file
            }
        }
        long toSend = end - start + 1;
        res.setContentLengthLong(Math.max(0, toSend));
        try (InputStream in = Files.newInputStream(file.toPath()); OutputStream out = res.getOutputStream()) {
            in.skipNBytes(start);
            byte[] buf = new byte[64 * 1024];
            while (toSend > 0) {
                int n = in.read(buf, 0, (int) Math.min(buf.length, toSend));
                if (n < 0) break;
                out.write(buf, 0, n);
                toSend -= n;
            }
        } catch (IOException clientClosed) {
            // the browser stopped reading (for example the video was skipped): not an error
        }
    }

    // ------------------------------------------------------------------ upload / delete
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User me = currentUser(req);
        res.setContentType("application/json;charset=UTF-8");

        if ("update".equals(param(req, "action"))) {          // admin edits the details of a study material
            File dir = folderFor("material", me, "", true);
            if (dir == null) { json(res, 403, "{\"ok\":false}"); return; }
            String err = updateMaterial(dir, req);
            if (err == null) json(res, 200, "{\"ok\":true}");
            else json(res, 400, "{\"ok\":false,\"error\":\"" + jsonEsc(err) + "\"}");
            return;
        }

        if ("delete".equals(param(req, "action"))) {
            String kind = param(req, "kind"), id = param(req, "id");
            if (!"material".equals(kind)) { json(res, 400, "{\"error\":\"Notes only\"}"); return; }
            File dir = folderFor(kind, me, "", true);
            if (dir == null) { json(res, 403, "{\"ok\":false}"); return; }
            if ("material".equals(kind) && !param(req, "entry").isEmpty()) {
                removeMaterial(dir, param(req, "entry"));
                json(res, 200, "{\"ok\":true}");
                return;
            }
            if (!STORED_ID.matcher(id).matches()) { json(res, 403, "{\"ok\":false}"); return; }
            File f = new File(dir, id);
            boolean gone = !f.exists() || f.delete();
            json(res, 200, "{\"ok\":" + gone + "}");
            return;
        }

        String kind = param(req, "kind");
        if (!"material".equals(kind)) { json(res, 400, "{\"error\":\"Notes only\"}"); return; }
        File dir = folderFor(kind, me, "", true);
        if (dir == null) { json(res, 403, "{\"error\":\"You are not allowed to upload here.\"}"); return; }
        Part part = req.getPart("file");
        if ("material".equals(kind) && "link".equals(param(req, "type")) && (part == null || part.getSize() == 0)) {
            String url = param(req, "url");
            if (!url.matches("(?i)https?://\\S{1,500}")) { json(res, 400, "{\"error\":\"Please enter a web address starting with http:// or https://\"}"); return; }
            long entry = addMaterial(dir, req, "", "", url, "Website");
            json(res, 200, "{\"entry\":" + entry + "}");
            return;
        }
        if (part == null || part.getSize() == 0) { json(res, 400, "{\"error\":\"Please choose a file.\"}"); return; }
        long max = "material".equals(kind) ? 200L * 1024 * 1024 : 10L * 1024 * 1024;
        if (part.getSize() > max) { json(res, 400, "{\"error\":\"File is larger than " + (max / 1024 / 1024) + " MB.\"}"); return; }

        String original = part.getSubmittedFileName() == null ? "file" : new File(part.getSubmittedFileName().replace('\\', '/')).getName();
        int dot = original.lastIndexOf('.');
        String ext = dot < 0 ? "" : original.substring(dot + 1).toLowerCase(Locale.ROOT);
        if (!TYPES.containsKey(ext)) {
            json(res, 400, "{\"error\":\"This file type is not allowed. Use PDF, Word, PowerPoint, Excel, ZIP, text, image or MP4 / WebM video.\"}");
            return;
        }
        String id = UUID.randomUUID().toString().replace("-", "") + "." + ext;
        try (InputStream in = part.getInputStream()) {
            Files.copy(in, new File(dir, id).toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
        String shown = safeName(original, "file." + ext, ext);
        String entry = "";
        if ("material".equals(kind)) entry = ",\"entry\":" + addMaterial(dir, req, id, shown, "", sizeLabel(part.getSize()));
        json(res, 200, "{\"id\":\"" + id + "\",\"name\":\"" + jsonEsc(shown) + "\",\"size\":" + part.getSize() + entry + "}");
    }


    // ------------------------------------------------------------------ shared list of study materials
    /** One line per material in data/uploads/material/index.tsv: every field is URL-encoded, fields are separated by a tab. */
    private static final Object INDEX_LOCK = new Object();

    private static File indexFile(File dir) { return new File(dir, "index.tsv"); }

    private static String enc(String v) { return URLEncoder.encode(v == null ? "" : v, StandardCharsets.UTF_8); }
    private static String dec(String v) { return URLDecoder.decode(v, StandardCharsets.UTF_8); }

    private static String sizeLabel(long bytes) {
        return bytes > 1048576 ? String.format(Locale.ROOT, "%.1f MB", bytes / 1048576.0) : Math.max(1, Math.round(bytes / 1024.0)) + " KB";
    }

    /** Adds one study material to the shared list and returns its number. */
    private long addMaterial(File dir, HttpServletRequest req, String fileId, String fileName, String url, String size) throws IOException {
        String type = param(req, "type");
        if (!Set.of("pdf", "slides", "video", "link").contains(type)) type = "pdf";
        String title = clip(param(req, "title"), 90), course = clip(param(req, "course"), 90), desc = clip(param(req, "desc"), 200);
        String lv = level(param(req, "lv"));
        synchronized (INDEX_LOCK) {
            long id = System.currentTimeMillis();
            String line = String.join("\t", enc(String.valueOf(id)), enc(title.isEmpty() ? "Untitled" : title), enc(course), enc(type),
                enc(desc.isEmpty() ? "No description." : desc), enc(LocalDate.now().toString()), enc(size), enc(fileId), enc(fileName), enc(url), enc(lv));
            Files.writeString(indexFile(dir).toPath(), line + System.lineSeparator(), StandardCharsets.UTF_8,
                java.nio.file.StandardOpenOption.CREATE, java.nio.file.StandardOpenOption.APPEND);
            return id;
        }
    }

    /** Changes title / course / description (and type or web address where allowed) of one material. Returns an error text, or null when done. */
    private String updateMaterial(File dir, HttpServletRequest req) throws IOException {
        String entry = param(req, "entry"), title = clip(param(req, "title"), 90), course = clip(param(req, "course"), 90), desc = clip(param(req, "desc"), 200);
        String type = param(req, "type"), url = param(req, "url");
        if (title.length() < 3) return "Please enter a title.";
        if (!Set.of("pdf", "slides", "video", "link").contains(type)) return "Unknown material type.";
        synchronized (INDEX_LOCK) {
            File idx = indexFile(dir);
            if (!idx.isFile()) return "Material not found.";
            List<String> lines = new ArrayList<>();
            boolean found = false;
            for (String line : Files.readAllLines(idx.toPath(), StandardCharsets.UTF_8)) {
                String[] f = line.split("\t", -1);
                if (f.length >= 10 && dec(f[0]).equals(entry)) {
                    boolean isLink = dec(f[7]).isEmpty();                     // a link has no stored file
                    if (isLink) {
                        if (!url.matches("(?i)https?://\\S{1,500}")) return "Please enter a web address starting with http:// or https://";
                        type = "link"; f[9] = enc(url);
                    } else if ("link".equals(type)) {
                        return "A file cannot be changed into a link. Upload a new link instead.";
                    }
                    f[1] = enc(title); f[2] = enc(course); f[3] = enc(type); f[4] = enc(desc.isEmpty() ? "No description." : desc);
                    if (f.length >= 11) f[10] = enc(level(param(req, "lv")));
                    else { f = java.util.Arrays.copyOf(f, 11); f[10] = enc(level(param(req, "lv"))); }   // older rows had no level column
                    line = String.join("\t", f);
                    found = true;
                }
                if (!line.isBlank()) lines.add(line);
            }
            if (!found) return "Material not found.";
            Files.write(idx.toPath(), lines, StandardCharsets.UTF_8);
        }
        return null;
    }

    private void removeMaterial(File dir, String entry) throws IOException {
        synchronized (INDEX_LOCK) {
            File idx = indexFile(dir);
            if (!idx.isFile()) return;
            List<String> keep = new ArrayList<>();
            for (String line : Files.readAllLines(idx.toPath(), StandardCharsets.UTF_8)) {
                String[] f = line.split("\t", -1);
                if (f.length >= 10 && dec(f[0]).equals(entry)) {
                    String fileId = dec(f[7]);
                    if (STORED_ID.matcher(fileId).matches()) new File(dir, fileId).delete();
                } else if (!line.isBlank()) keep.add(line);
            }
            Files.write(idx.toPath(), keep, StandardCharsets.UTF_8);
        }
    }

    private void listMaterials(HttpServletResponse res) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        res.setHeader("Cache-Control", "no-store");
        File idx = indexFile(folderFor("material", null, "", false));
        StringBuilder sb = new StringBuilder("[");
        if (idx.isFile()) {
            boolean first = true;
            synchronized (INDEX_LOCK) {
                for (String line : Files.readAllLines(idx.toPath(), StandardCharsets.UTF_8)) {
                    String[] f = line.split("\t", -1);
                    if (f.length < 10) continue;
                    if (!first) sb.append(',');
                    first = false;
                    sb.append("{\"id\":").append(dec(f[0]).replaceAll("[^0-9]", "0"))
                      .append(",\"title\":\"").append(jsonEsc(dec(f[1]))).append("\",\"course\":\"").append(jsonEsc(dec(f[2])))
                      .append("\",\"type\":\"").append(jsonEsc(dec(f[3]))).append("\",\"desc\":\"").append(jsonEsc(dec(f[4])))
                      .append("\",\"date\":\"").append(jsonEsc(dec(f[5]))).append("\",\"size\":\"").append(jsonEsc(dec(f[6])))
                      .append("\",\"fileId\":\"").append(jsonEsc(dec(f[7]))).append("\",\"fileName\":\"").append(jsonEsc(dec(f[8])))
                      .append("\",\"url\":\"").append(jsonEsc(dec(f[9])))
                      .append("\",\"lv\":\"").append(jsonEsc(f.length > 10 ? dec(f[10]) : "")).append("\"}");   // learner level (empty = older material)
                }
            }
        }
        res.getWriter().write(sb.append(']').toString());
    }

    /** The learner level a material is meant for: CHILD / SCHOOL / AL / UNDERGRAD (anything else = "" = not set). */
    private static String level(String v) {
        return Set.of("CHILD", "SCHOOL", "AL", "UNDERGRAD").contains(v) ? v : "";
    }

    private static String clip(String s, int max) { return s.length() > max ? s.substring(0, max) : s; }

    // ------------------------------------------------------------------ helpers
    /**
     * The folder a request may use, or null when it is not allowed.
     * write=true is used for upload / delete.
     */
    private File folderFor(String kind, User me, String uidParam, boolean write) {
        File base = new File(AppConfig.dataDir(), "uploads");
        if ("material".equals(kind)) {
            if (write && (me == null || !me.canManageUsers())) return null;         // only admins add / remove materials
            return ensure(new File(base, "material"));
        }
        return null;
    }

    private static File ensure(File dir) { if (!dir.exists()) dir.mkdirs(); return dir; }

    /** Keeps only harmless characters, so the name is safe inside the Content-Disposition header. */
    static String safeName(String name, String fallback, String ext) {
        String n = name == null ? "" : name.replaceAll("[^\\p{L}\\p{N} ._()\\-]", "_").trim();
        if (n.isEmpty()) n = fallback;
        if (n.length() > 120) n = n.substring(0, 120);
        // header values must stay ASCII
        StringBuilder sb = new StringBuilder();
        for (char c : n.toCharArray()) sb.append(c < 128 ? c : '_');
        return sb.toString();
    }

    private static String jsonEsc(String s) {
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"': sb.append("\\\""); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default: if (c < 0x20) sb.append(String.format("\\u%04x", (int) c)); else sb.append(c);
            }
        }
        return sb.toString();
    }

    private static void json(HttpServletResponse res, int status, String body) throws IOException {
        res.setStatus(status);
        res.getWriter().write(body);
    }
}
