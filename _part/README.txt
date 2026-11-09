Part 2 - Course Details
=======================

/course-details: course grid + detail page. ADMIN: add / edit / delete course is inside course-details.jsp.

RUN ALONE : open this folder in IntelliJ (the one with pom.xml) -> run src/main/java/com/lms/student/Main.java -> http://localhost:8080
LOGIN     : admin A001 / Admin@123   students S001..S012 / Student@123
MERGE     : copy src/ of several parts into one folder (see ../MERGE-README.txt) - no file clashes, same sidebar.

This part adds : src/main/java/com/lms/student/servlet/CourseDetailsServlet.java
  + src/main/webapp/WEB-INF/views/modules/course-details.jsp

_part/levels/<child | grade-1-11 | al | undergraduate> : the UI theme css + courses of each learner level (reference slices of the real css/themes.css and js/courses.js).
The page itself is one file for all four levels; it changes with the logged-in student level (<body class="theme-...">).
