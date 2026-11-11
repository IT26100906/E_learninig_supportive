# Part 01 — Login, Signup, Home and Student Administration

The original LearnHub home page, original CSS/JS/images, login and registration remain intact.

## Student pages
- `/` — original home page
- `/register` — student signup
- `/login` — login
- `/dashboard` — student dashboard (authentication required)

## Admin pages (admin login required)
- `/admin/dashboard` — admin home page, with Add Student and Student Management cards
- `/admin/students/form` — add student
- `/admin/students` — manage/search/edit/activate/deactivate/delete students
- `/admin/students/form?id=<studentId>` — edit existing student

The original admin Java controllers and JSPs have been retained, together with UserService and user repositories. The new Admin Login link on the public homepage goes to the *existing* login page, not an unprotected admin view. After login, the original LoginServlet redirects admins to the admin dashboard automatically.

## Start
1. Extract the ZIP and open `01-Login-Signup-Home` (the folder containing `pom.xml`) in IntelliJ.
2. Load Maven dependencies, run `mvn clean compile` or use the Maven panel.
3. Run `com.lms.student.Main`.
4. Open http://localhost:8080/. Log in with an existing admin account to access student management.
5. Database settings are in `src/main/resources/db.properties`; ensure the configured database server is available.

Note: Compiling and running the project needs Java, Maven, and the configured database. The changes were checked for file/path consistency, not executed in a live browser here.
