Part 1 - Home, Sign In, Sign Up (+ admin students pages)
========================================================

Home page, Sign In, Sign Up (level + grade / stream / degree picker), Forgot / Change password, Logout, profile, 4 level dashboards.
ADMIN: admin/dashboard, admin/students (list, search, level filter), admin/student-form (add / edit), admin/database.
This part is also the BASE of every other part (login + database + layout).

RUN ALONE : open this folder in IntelliJ (the one with pom.xml) -> run src/main/java/com/lms/student/Main.java -> http://localhost:8080
LOGIN     : admin A001 / Admin@123   students S001..S012 / Student@123
MERGE     : copy src/ of several parts into one folder (see ../MERGE-README.txt) - no file clashes, same sidebar.

This part adds : the whole login / home / admin-students base

_part/levels/<child | grade-1-11 | al | undergraduate> : the UI theme css + dashboard jsp of each learner level (reference slices of the real css/themes.css and js/courses.js).
The page itself is one file for all four levels; it changes with the logged-in student level (<body class="theme-...">).
