# 06-Assignments — separated from ORIGINAL StudentApp ZIP
# 05-Course-Enrollment

This folder contains only this member's identified feature-specific source files (Java, JSP, and some JS). Paths are preserved so you can copy them into the full project.

**Not independently runnable:** Shared controllers, models, database configuration, CSS, common JSPs, and utilities live in `08-Shared-Core`. Use `00-Full-Integrated-StudentApp/StudentApp` to run the complete application.

The shared `ModuleUiServlet`, `StoreServlet`, `FileServlet`, and browser `modules.js` serve multiple modules and are intentionally kept in Shared-Core rather than attributed to one member.
# 02-Course-Details — separated from ORIGINAL StudentApp ZIP

This is an independent IntelliJ/Maven preview of the original StudentApp UI.
The module JSP, background images, CSS, original JS and functionality come from `StudentApp_PawPal_Style_Reorganized(1).zip`, not a redesigned page.

Run: open this exact folder in IntelliJ IDEA (with `pom.xml`), Maven `clean` and `compile`, run `com.lms.student.Main`, open http://localhost:8080/.
Use Student View / Admin View (DEMO ONLY) to switch roles.
Do not run two modules on port 8080 simultaneously; set VM option `-Dport=8081` on the second.
These demo roles bypass real login; do NOT deploy publicly.

Feature: assignments.
Feature: course-details.
