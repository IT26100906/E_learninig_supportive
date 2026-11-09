# LearnHub - Student Account Management (Member 1)

SE1020 Project - JSP/Servlet web app, **SQL database storage** (H2 or MySQL), Bootstrap 5 UI.

## Run in IntelliJ IDEA (Community or Ultimate)
1. **File > Open** and choose the `StudentApp` folder (the one with `pom.xml`). Wait for Maven to download the dependencies (internet needed the first time).
2. Make sure **Project SDK = JDK 17 or newer** (File > Project Structure > Project).
3. Open `src/main/java/com/lms/student/Main.java` and click the green **Run** arrow next to `main`.
   (Tomcat is embedded, nothing else to install.)
4. Open **http://localhost:8080/** in the browser.

Alternative from a terminal: `mvn compile exec:java`

> If port 8080 is busy: Run > Edit Configurations > VM options `-Dport=9090`.
> Always run from the project root folder (working directory = `StudentApp`).

## Database
All users are saved in a real SQL database - table `users` (see `database/schema-mysql.sql`).
The tables are created automatically when the app starts.

| Option | What to do |
|---|---|
| **H2 (default)** | Nothing. Data is stored in `data/lmsdb.mv.db` inside the project folder. |
| **MySQL / MariaDB** | Start MySQL (XAMPP etc.), open `src/main/resources/db.properties`, comment out `db.type=h2`, un-comment the two `mysql` lines and set `db.user` / `db.password`. The `learnhub` database is created for you. |

You can also switch without editing files: VM options `-Ddb.type=mysql -Ddb.user=root -Ddb.password=secret`.

**First start:** if the old `data/users.txt` exists and the table is empty, its users are copied into the database
once and the file is renamed to `users.txt.imported`. (To start from zero, delete `data/lmsdb.mv.db`.)
Profile pictures are still saved as files in `data/profile-pics/` (the table stores only the file name).

### Viewing the data (phpMyAdmin)
Log in as admin and open **Database** (sidebar / admin dashboard, `/admin/database`): a read-only in-app view of ALL tables
(users, payments, courses, enrollments, pending_invoices, assignments, study_materials, course_reviews, app_data) - works with H2 and MySQL,
password/hash columns are hidden. For MySQL you can also click **phpMyAdmin** (sidebar or admin dashboard) -
it opens the `learnhub` database in phpMyAdmin (`http://localhost/phpmyadmin`) in a new tab.
If phpMyAdmin is on another address, set `db.phpmyadmin` in `db.properties`. Needs `db.type=mysql`.

### What you see in phpMyAdmin (database `learnhub`)
| Table | Contents |
|---|---|
| `users` | all student + admin details (name, email, phone, level, status ...) |
| `courses` | the course catalogue (built-in courses + admin add / edit / delete) |
| `enrollments` | who is enrolled in which course, progress, payment status (`recorded_by` STUDENT / ADMIN) |
| `payments` | payments (`origin` STUDENT = paid by a student, ADMIN = admin payment list) |
| `pending_invoices` | unpaid invoices of each student |
| `assignments`, `study_materials`, `course_reviews` | assignments + marks, study materials, reviews |

These tables are updated automatically **every time something changes in the website** (class `DataMirror`), and all
data saved earlier is copied in when the app starts. Direction is website -> database: editing a row by hand in
phpMyAdmin does not change the website. `app_data` is the app's own storage (JSON) - leave it alone.

### Assignments + Course Notes by learner level (admin)
**Assignments** (`/assignments`): the admin page splits assignments into **Child / Grade 1-11 / A/L / Undergraduate** tabs. The admin creates an assignment
for a level and one of its courses; a student only sees the assignments of his / her own level (and own courses). When a student submits a file, the admin opens
**Submissions & marks** on the assignment, sees every student of that level (not submitted / submitted / marked), views or downloads the file, and gives marks + feedback.
The student then sees the marks on the Assignments page. Marks can only be written by an admin (`POST /store action=grade`).
Stored in `app_data`: `adm-asg` (shared, the assignments), `asg-s-<id>` (a student's submission), `asg-g-<id>` (the marks); table `assignments` shows them readable.
**Course Notes** (`/course-notes`): the admin page has the same four level tabs; an uploaded material gets a learner level + a course of that level, and students only see
the materials of their own level.

### Module pages are saved in the database too
Course Details (admin changes), Enrollment, Feedback, Notes (saved / counters), Assignments and Payment pages now save everything in table **`app_data`**
(`owner_id`, `data_key`, `data_value` = JSON text) through `StoreServlet` (`/store`, and `/js/store.js` which hands the saved data to the page).
`owner_id` is the student / admin ID, or `*` for data shared by everybody (`courses-overlay`, `reviews`, `adm-enr`, `adm-pay`).
Payments are also kept in the real `payments` table. The pages still call `LH.load(...)` / `LH.save(...)` - only the storage behind them changed
(`js/modules.js`). Data an older version kept in the browser (localStorage) is copied into the database the first time that user opens the page.

## Demo accounts (imported from data/users.txt on first start)
| Role | ID | Password |
|---|---|---|
| Admin | `A001` | `Admin@123` |
| Students | `S001` ... `S012` | `Student@123` |

(`S004` and `S009` are INACTIVE, so they cannot log in.)

## Features
**Student:** register, login/logout, dashboard, view profile, edit profile (phone, DOB, address), profile picture upload, change password (with strength meter), forgot password (security question). Students cannot delete their own account (only an admin can).
**Admin:** dashboard with statistics, add / edit / delete students, activate / deactivate, change membership (Regular / Premium), reset password, search (ID / name / email), filter by status, sort, pagination, export CSV.
**Security:** PBKDF2 password hashing with salt, server-side validation, XSS-safe output (`<c:out>`), POST for all changes, session login filter, admin-only URLs, safe image upload (checks real file type, 2 MB max), inactive accounts blocked.

### Admin course pages (demo data in the browser)
- **Course Details** - four separate parts (Child / Grade 1 - 11 / A/L / Undergraduate); add, view, **edit** (every detail: fee, seats, schedule, description, learn points, requirements, syllabus) and delete a course. Changes are kept as an overlay (`localStorage`), so students in the same browser see them.
- **Course Notes / Study Materials** - admin can upload, **edit** (title, course, type, description, link address) and delete a material. Uploaded materials are edited on the server (`POST /files action=update`).
- **Course Enrollment** (`modules/admin-enrollment.jsp`) - the enrollments of the real students, split by learner level; **view, create, edit, delete**. Only courses that suit the chosen student are offered.
- **Course Feedback** - reviews split by level; admin can **view** a review in full and **delete** it.
- **Payment** (`modules/admin-payment.jsp`) - the students who have paid (name, ID, level, course, method, reference, amount), split by level; **view** the receipt details and **delete** a record.

## Pages (JSP)
`home, login, register, forgot-password, dashboard, profile, edit-profile, change-password, error, admin/dashboard, admin/students, admin/student-form, modules/course-feedback, modules/course-notes, modules/course-enrollment, modules/assignments, modules/payment, modules/admin-enrollment, modules/admin-payment`

## Project structure
```
src/main/java/com/lms/student
  model/       User (abstract), Student, PremiumStudent, Admin, UserFactory, AccountStatus, Page<T>
  repository/  UserRepository (interface), JdbcUserRepository (SQL database), FileUserRepository (old users.txt, used only for the one-time import)
  service/     UserService, ValidationException, AuthException
  servlet/     BaseServlet + all servlets (AdminPhpMyAdminServlet = admin link to phpMyAdmin)
  filter/      AuthFilter
  listener/    AppInitListener (connects to the database, creates table + default admin)
  util/        PasswordUtil, Validator, AppConfig, DbConfig (reads db.properties)
src/main/webapp/WEB-INF/views   JSP pages (opened only through servlets)
src/main/resources/db.properties  database settings (H2 / MySQL)
database/schema-mysql.sql       table definition for MySQL
data/users.txt                  sample users (imported into the database on first start)
docs/                           class diagram + OOP/file-handling notes (for the report and viva)
```

## For the other group members
The **Student ID** (`User.getId()`) is the common key. Course / Enrollment modules can call
`new UserService().findById(id)` and use `student.getMaxEnrollments()` for the course limit.
The logged-in student ID is in the session attribute `userId`; the full object is `request.getAttribute("currentUser")`.

## Table `users`
`id (PK), user_type, name, email (unique), password_hash, phone, date_of_birth, address, status, registered_date, last_login, profile_picture, security_question, security_answer_hash, student_level, level_detail`

## Sidebar (menu button)
The 4-line button before "LearnHub" opens a white sidebar: Home, Course Details, Course Notes / Study Materials,
Course Enrollment, Assignment, Course Feedback / Reviews, Payment (admins also get Students and Add Student).
Those module pages are opened by `ModuleUiServlet` (UI with sample data). When a teammate's real servlet is merged, delete its URL from the
`@WebServlet({...})` list in `ModuleUiServlet` (two servlets cannot use the same URL). The sidebar links are in `common/header.jsp`.

## Look & feel
* Home page = full-screen photo with LearnHub branding, Sign In / Sign Up buttons (`views/home.jsp`).
* Sign in / Sign up / Reset password use frosted-glass cards with pill inputs.
* Light mode uses `images/main-bg.jpg` on every page (`css/style.css`, `css/themes.css`); dark mode uses `images/dark-bg.jpg` everywhere (`css/dark.css`). Replace the image files to change them.
* "Remember me" stores only the Student ID in a cookie for 30 days (never the password).

## Learner levels (different UI for each)
At sign up the student chooses **Child (ages 3-7) / Grade 1-11 / A/L / Undergraduate** and gives the age, grade, stream or degree.
Each level gets its own theme (`css/themes.css`) and its own dashboard page:

| Level | Dashboard page | Look |
|---|---|---|
| Child | `dashboard-child.jsp` | bright, playful, big picture tiles |
| Grade 1-11 | `dashboard-school.jsp` | notebook paper, green, subject cards for that grade |
| A/L | `dashboard-al.jsp` | dark focus mode, study toolkit, subjects of the chosen stream |
| Undergraduate | `dashboard-undergrad.jsp` | glass look over the photo |

Admins can see and change the level of every student (Students page has a level filter).
Sample users: S004/S008 = Child, S002/S005/S009/S011 = Grade, S003/S007/S012 = A/L, S001/S006/S010 = Undergraduate.

## Module UI pages (Course Details, Feedback, Notes, Enrollment, Assignment, Payment)
| URL | JSP | What it has |
|---|---|---|
| `/course-details` | `views/modules/course-details.jsp` | course grid (search / category / level / sort), full detail page per course (`#C101`): about, what you learn, syllabus accordion, instructor, schedule, seats + fee, Enroll / Notes / Reviews / Payment links; admin: add / delete course |
| `/course-feedback` | `views/modules/course-feedback.jsp` | rating summary + breakdown, search / filter / sort, write a review (star picker), helpful votes, delete own review (admin: any) |
| `/course-notes` | `views/modules/course-notes.jsp` | study-material cards (PDF / slides / video / link), type tabs, search, save for later, download counter, admin upload form |
| `/course-enrollment` | `views/modules/course-enrollment.jsp` | course catalog with seats + fee, enrollment-limit bar (uses `currentUser.maxEnrollments`: Regular / Premium), confirm dialog, "My enrollments" with progress and Drop |
| `/assignments` | `views/modules/assignments.jsp` | status tabs (Pending / Overdue / Submitted / Graded), deadline countdown, file submit, marks + feedback, admin: create / grade / delete |
| `/payment` | `views/modules/payment.jsp` | totals, pending invoices, pay dialog (card with live preview + Luhn check, bank slip, wallet), history, printable receipt |

* All six are opened by `ModuleUiServlet` (login required). The old `ModulePlaceholderServlet` and `module-placeholder.jsp` were removed.
* These pages start from sample data and save every change in the database (table `app_data`, see above). Card details are never stored or sent.
* To connect the real back-end: replace the sample arrays at the top of each page script (`SEED...`) with data from your servlet / DAO (e.g. `request.setAttribute(...)` + `<c:forEach>` or a JSON endpoint) and turn the `LH.save(...)` calls into `fetch()` POSTs.
* Shared files: `css/modules.css`, `js/modules.js` (linked from `common/header.jsp` / `common/footer.jsp`).

## Readability (light / dark mode)
`css/readable.css` is loaded last (from `common/header.jsp`). Light mode uses dark liquid-glass panels with white text, so it forces
readable colours for Bootstrap utility classes, status chips, date / file inputs and dropdown options. The home page now uses white text over a
darker overlay (the photo behind it is mid-dark, so black text was hard to read).

## Courses follow the learner level
`js/courses.js` holds the course catalogue (47 sample courses) and picks the ones that fit the logged-in student. The same data feeds
Course Details, Enrollment, Notes, Assignments, Feedback and Payment, so every page shows the right courses for that learner:

| Level | Courses shown |
|---|---|
| Child (age 3-7) | story, numbers, art, songs, nature, letters, (coding from age 6) |
| Grade 1-11 | by grade band: Grades 1-5, 6-9, 10-11 (O/L); Grade 5 gets the Scholarship exam course |
| A/L | by stream (Physical, Biological, Commerce, Arts, Technology) + common subjects (General English, GIT, ICT) |
| Undergraduate | chosen from the **degree dropdown** at sign-up (32 degrees in 6 faculties); each degree gets its own set of courses (about 7 - 17) + general skills courses |
| Admin | all courses (Course Details has a "learner level" filter) |

Each page shows a "Courses chosen for you" strip under the title. Demo data is stored per user (localStorage key `lh-demo-<userId>-...`).
To use real data, replace `LH.allCourses()` / the `LH.seed*` functions in `courses.js` with your servlet data.

## Light mode text colour
All text is white on the dark glass in light mode. `css/readable.css` fixes the known dark colours and `js/readable.js` (contrast guard,
light mode only) turns any remaining black / dark-grey text white, including content added later by scripts.

## Sign-up: degree dropdown (Undergraduate)
The "Degree / Course" box is now a drop-down list grouped by faculty (Computing & IT, Business & Management, Engineering & Built Environment,
Science, Health Sciences, Law / Arts & Education). The list is `StudentLevel.UG_DEGREES` (Java) and the same names are mapped to course groups in
`DEGREES` inside `js/courses.js` - when you add a degree, add it in both places. An old free-text degree is kept as an extra option so editing
an existing student does not lose it. The same picker is used by Register and Admin > Add / Edit student.

## Course Details buttons
Course Details > View details shows **Open study materials** (enabled once enrolled) and **Enrollment** (opens `/course-enrollment#<courseId>`,
scrolls to that course and highlights it). The Payment button was removed from that page (Payment stays in the sidebar).

## Study materials, videos and submissions (file handling)

- `FileServlet` (`/files`) stores real files in `data/uploads/` (change the folder with `-Dlms.data.dir`).
  - **Course Notes**: students can *Open* (PDF / images / text open in a new tab), *Download* (saved to their device) and *Watch* videos
    (MP4 / WebM play in a pop-up player with seeking). Admins upload PDF, Word, PowerPoint, Excel, ZIP, MP4 / WebM or a web link; uploads are shared with every
    student whose course list contains that course.
  - **Assignments**: the file a student submits is stored per student; the student can *View* and *Download* it again at any time
    (only that student and admins can open it). *Unsubmit* removes the stored file.
- `data/uploads/` is ignored by git. `src/main/webapp/media/sample-lesson.mp4` is the demo video used by the sample lessons.
- **Course lists**: `js/courses.js` shows only the courses that match the category chosen at sign-up (Child age, Grade, A/L stream, Undergraduate degree).
  The "Free Starter" courses now follow the same rule, so an IT-degree student no longer sees Law or Health starters.
