-- LearnHub - MySQL / MariaDB schema (optional: the app also creates this by itself on start-up)
CREATE DATABASE IF NOT EXISTS learnhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE learnhub;

CREATE TABLE IF NOT EXISTS users (
  id                   VARCHAR(12)  NOT NULL PRIMARY KEY,   -- Student ID, e.g. S001 / A001
  user_type            VARCHAR(10)  NOT NULL,               -- STUDENT | PREMIUM | ADMIN
  name                 VARCHAR(100) NOT NULL,
  email                VARCHAR(100) NOT NULL,
  password_hash        VARCHAR(255) NOT NULL,               -- salted PBKDF2 hash, never the real password
  phone                VARCHAR(20),
  date_of_birth        DATE,
  address              VARCHAR(255),
  status               VARCHAR(10)  NOT NULL,               -- ACTIVE | INACTIVE
  registered_date      DATE         NOT NULL,
  last_login           DATETIME,
  profile_picture      VARCHAR(255),                        -- file name inside data/profile-pics
  security_question    VARCHAR(255),
  security_answer_hash VARCHAR(255),
  student_level        VARCHAR(12)  NOT NULL,               -- CHILD | SCHOOL | AL | UNDERGRAD
  level_detail         VARCHAR(100),                        -- age / grade / stream / degree
  CONSTRAINT uq_users_email UNIQUE (email)
);

-- Data of the module pages (enrollments, reviews, assignments, payment lists, course changes ...), one JSON text per (owner, key).
-- owner_id = student/admin ID, or '*' for data shared by everybody.
CREATE TABLE IF NOT EXISTS app_data (
  owner_id   VARCHAR(12) NOT NULL,
  data_key   VARCHAR(40) NOT NULL,
  data_value MEDIUMTEXT  NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (owner_id, data_key)
);

-- payments table (created by the app too)
CREATE TABLE IF NOT EXISTS payments (
  receipt_no VARCHAR(40) NOT NULL PRIMARY KEY,
  student_id VARCHAR(12) NOT NULL,
  course     VARCHAR(150) NOT NULL,
  descr      VARCHAR(200),
  amount     DECIMAL(12,2) NOT NULL,
  pay_date   VARCHAR(10) NOT NULL,
  pay_method VARCHAR(30) NOT NULL,
  pay_ref    VARCHAR(120),
  origin     VARCHAR(10) DEFAULT 'STUDENT'          -- STUDENT = paid by a student, ADMIN = from the admin payment list
);

-- ---------------------------------------------------------------------------------------------
-- Readable copies of the module-page data (the app fills and updates these by itself, every time
-- something changes in the website; app_data above stays the app's own storage).
-- ---------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
  course_id VARCHAR(12) NOT NULL PRIMARY KEY, level_code VARCHAR(12), name VARCHAR(150) NOT NULL,
  category VARCHAR(60), difficulty VARCHAR(20), fee DECIMAL(12,2), duration_weeks INT, is_free BOOLEAN,
  instructor VARCHAR(100), schedule VARCHAR(100), lang VARCHAR(80), seats INT, seats_taken INT,
  descr VARCHAR(1000), topics VARCHAR(1000));

CREATE TABLE IF NOT EXISTS enrollments (            -- recorded_by: STUDENT = student's own page, ADMIN = admin list
  recorded_by VARCHAR(8) NOT NULL, student_id VARCHAR(12) NOT NULL, course_id VARCHAR(12) NOT NULL,
  course_name VARCHAR(150), enrolled_date VARCHAR(10), progress_pct INT, lessons_done INT, payment_status VARCHAR(12),
  PRIMARY KEY (recorded_by, student_id, course_id));

CREATE TABLE IF NOT EXISTS pending_invoices (
  student_id VARCHAR(12) NOT NULL, invoice_no VARCHAR(30) NOT NULL, course_name VARCHAR(150),
  descr VARCHAR(200), amount DECIMAL(12,2), due_date VARCHAR(10), PRIMARY KEY (student_id, invoice_no));

CREATE TABLE IF NOT EXISTS assignments (
  owner_id VARCHAR(12) NOT NULL, assignment_id INT NOT NULL, title VARCHAR(200), course_name VARCHAR(150),
  due_date VARCHAR(10), total_marks INT, status VARCHAR(12), score INT, feedback VARCHAR(500),
  submitted_date VARCHAR(10), file_name VARCHAR(200), descr VARCHAR(1000), level_code VARCHAR(12), PRIMARY KEY (owner_id, assignment_id));
-- owner_id '*' = the assignment itself (status ASSIGNED, level_code = CHILD / SCHOOL / AL / UNDERGRAD);
-- owner_id = student id = that student's submission (status SUBMITTED, or GRADED once the admin gave marks).

CREATE TABLE IF NOT EXISTS study_materials (
  owner_id VARCHAR(12) NOT NULL, material_id INT NOT NULL, title VARCHAR(200), course_name VARCHAR(150),
  material_type VARCHAR(12), size_text VARCHAR(30), upload_date VARCHAR(10), downloads INT, descr VARCHAR(1000),
  PRIMARY KEY (owner_id, material_id));

CREATE TABLE IF NOT EXISTS course_reviews (
  review_id INT NOT NULL PRIMARY KEY, student_id VARCHAR(20), reviewer_name VARCHAR(100), anonymous BOOLEAN,
  course_name VARCHAR(150), rating INT, title VARCHAR(150), review_text VARCHAR(2000),
  review_date VARCHAR(10), helpful_votes INT);
