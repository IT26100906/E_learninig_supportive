PART 06: Assignments
Open THIS folder (not the parent ZIP folder) in IntelliJ IDEA as a Maven project.
Run com.lms.student.Main, then open http://localhost:8080/ .
This launches DIRECTLY into /assignments. No other member pages are included.
Use Student View / Admin View in the top bar to preview this module's user/admin features.
Course Details, Course Notes and Feedback manage their admin actions within the same page.
The modules admin-assignments are bundled only with this part.
PART 03: Course Feedback
Open THIS folder (not the parent ZIP folder) in IntelliJ IDEA as a Maven project.
Run com.lms.student.Main, then open http://localhost:8080/ .
This launches DIRECTLY into /course-feedback. No other member pages are included.
PART 02: Course Details
Open THIS folder (not the parent ZIP folder) in IntelliJ IDEA as a Maven project.
Run com.lms.student.Main, then open http://localhost:8080/ .
This launches DIRECTLY into /course-details. No other member pages are included.
Use Student View / Admin View in the top bar to preview this module's user/admin features.
Course Details, Course Notes and Feedback manage their admin actions within the same page.
The modules (no separate admin JSP) are bundled only with this part.
Java sources: controller/ModuleUiServlet.java (this feature), StoreServlet.java (shared storage API), BaseServlet.java (JSP helpers), plus necessary model/repository/service/util. FileServlet/PaymentRecordServlet only where needed.
Uses independent H2 local data under this project/data (no MySQL setup required). Database backend and persistence remain available.
IMPORTANT: DemoModeFilter is for localhost preview, NOT for public deployment. To integrate into the real site replace this demo filter and role switch with the production AuthFilter/login from Part 01.
Stop all other Main processes before starting this part (port 8080).
