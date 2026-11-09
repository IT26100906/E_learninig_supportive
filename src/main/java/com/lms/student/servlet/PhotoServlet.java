package com.lms.student.servlet;

import com.lms.student.model.User;
import com.lms.student.util.AppConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;

/**
 * Profile picture handling.
 *  GET  /photo?id=S001           -> shows the picture (owner or admin only)
 *  POST /profile/photo           -> upload a new picture (jpg/png/gif, max 2 MB)
 *  POST /profile/photo/remove    -> remove the picture
 * Pictures are stored in data/profile-pics/ and named after the user ID (never the uploaded name).
 */
@WebServlet(urlPatterns = {"/photo", "/profile/photo", "/profile/photo/remove"})
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 3 * 1024 * 1024)
public class PhotoServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User me = currentUser(req);
        String id = param(req, "id");
        if (!me.getId().equalsIgnoreCase(id) && !me.canManageUsers()) {
            res.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        User target = userService.findById(id).orElse(null);
        if (target == null || target.getProfilePicture() == null || target.getProfilePicture().isBlank()) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        File file = new File(AppConfig.photoDir(), new File(target.getProfilePicture()).getName());
        if (!file.exists()) { res.sendError(HttpServletResponse.SC_NOT_FOUND); return; }

        String name = file.getName().toLowerCase();
        res.setContentType(name.endsWith(".png") ? "image/png" : name.endsWith(".gif") ? "image/gif" : "image/jpeg");
        res.setHeader("X-Content-Type-Options", "nosniff");
        res.setContentLengthLong(file.length());
        Files.copy(file.toPath(), res.getOutputStream());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        User u = currentUser(req);

        if (req.getServletPath().endsWith("/remove")) {
            deleteOldPicture(u);
            userService.setProfilePicture(u, "");
            flash(req, "info", "Profile picture removed.");
            redirect(req, res, "/profile");
            return;
        }

        try {
            Part part = req.getPart("photo");
            if (part == null || part.getSize() == 0) {
                flash(req, "danger", "Please choose an image file.");
                redirect(req, res, "/profile");
                return;
            }
            String ext = detectExtension(part);
            if (ext == null) {
                flash(req, "danger", "Only JPG, PNG or GIF images are allowed.");
                redirect(req, res, "/profile");
                return;
            }
            deleteOldPicture(u);
            String fileName = u.getId().toLowerCase() + "." + ext;
            try (InputStream in = part.getInputStream()) {
                Files.copy(in, new File(AppConfig.photoDir(), fileName).toPath(),
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING);
            }
            userService.setProfilePicture(u, fileName);
            flash(req, "success", "Profile picture updated.");
        } catch (IllegalStateException e) {   // file bigger than the limit
            flash(req, "danger", "The image is too large (maximum 2 MB).");
        }
        redirect(req, res, "/profile");
    }

    /** Checks the first bytes of the file (not the file name) to find the real image type. */
    private String detectExtension(Part part) throws IOException {
        byte[] h = new byte[8];
        int n;
        try (InputStream in = part.getInputStream()) { n = in.read(h); }
        if (n >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF) return "jpg";
        if (n >= 4 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G') return "png";
        if (n >= 4 && h[0] == 'G' && h[1] == 'I' && h[2] == 'F' && h[3] == '8') return "gif";
        return null;
    }

    private void deleteOldPicture(User u) {
        String old = u.getProfilePicture();
        if (old != null && !old.isBlank()) new File(AppConfig.photoDir(), new File(old).getName()).delete();
    }
}
