package com.lms.student.service;

import com.lms.student.model.*;
import com.lms.student.repository.JdbcUserRepository;
import com.lms.student.repository.UserRepository;
import com.lms.student.util.PasswordUtil;
import com.lms.student.util.Validator;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/** All business rules for Student Account Management (validation, login, CRUD, search ...). */
public class UserService {

    public static final List<String> SECURITY_QUESTIONS = List.of(
        "What is your pet's name?",
        "What is your mother's maiden name?",
        "What was the name of your first school?",
        "What is your favourite teacher's name?",
        "In which town were you born?");

    private final UserRepository repo;

    public UserService() { this(JdbcUserRepository.getInstance()); }

    public UserService(UserRepository repo) { this.repo = repo; }

    // =================== CREATE ===================

    /** Registers a new student (also used by admin "Add student"). */
    public Student register(String id, String name, String email, String password, String confirm,
                            String phone, String dob, String address,
                            String question, String answer, boolean premium,
                            String levelCode, String levelDetail) throws ValidationException {
        id = Validator.clean(id); name = Validator.clean(name); email = Validator.clean(email);
        phone = Validator.clean(phone); address = Validator.clean(address);
        dob = Validator.clean(dob); question = Validator.clean(question); answer = Validator.clean(answer);
        levelDetail = Validator.clean(levelDetail);
        if (id.isEmpty()) id = nextStudentId();      // sign-up no longer asks for an ID

        List<String> errors = new ArrayList<>();
        if (!Validator.isValidId(id))
            errors.add("Student ID must be 3-12 letters/digits and start with a letter (e.g. S001).");
        else if (repo.findById(id).isPresent())
            errors.add("Student ID '" + id + "' already exists.");
        if (!Validator.isValidName(name))
            errors.add("Name must be 2-60 characters (letters, spaces, . ' - only).");
        if (!Validator.isValidEmail(email))
            errors.add("Please enter a valid email address.");
        else if (repo.findByEmail(email).isPresent())
            errors.add("This email is already registered.");
        if (!Validator.isStrongPassword(password))
            errors.add("Password must be 6-64 characters with at least one letter and one digit.");
        else if (!password.equals(confirm))
            errors.add("Password and confirm password do not match.");
        if (!Validator.isValidPhone(phone))
            errors.add("Phone number must be 9-15 digits (optional + at the start).");
        if (!Validator.isValidBirthDate(dob))
            errors.add("Date of birth must be a valid past date.");
        if (!SECURITY_QUESTIONS.contains(question))
            errors.add("Please choose a security question.");
        if (answer.length() < 2)
            errors.add("Please enter an answer to the security question.");
        StudentLevel level = StudentLevel.parse(levelCode);
        if (level == null)
            errors.add("Please choose who you are: Child, Grade 1-11, A/L or Undergraduate.");
        else if (!level.isValidDetail(levelDetail))
            errors.add("Please enter a valid value for: " + level.getDetailLabel() + ".");
        if (!errors.isEmpty()) throw new ValidationException(errors);

        Student s = (Student) UserFactory.create(premium ? "PREMIUM" : "STUDENT",
                id, name, email, PasswordUtil.hash(password));
        s.setPhone(phone);
        s.setAddress(address);
        s.setDateOfBirth(dob.isEmpty() ? null : LocalDate.parse(dob));
        s.setSecurityQuestion(question);
        s.setSecurityAnswerHash(PasswordUtil.hash(PasswordUtil.normalizeAnswer(answer)));
        s.setRegisteredDate(LocalDate.now());
        s.setLevel(level);
        s.setLevelDetail(levelDetail);
        repo.create(s);
        return s;
    }

    /** Next free Student ID: S + running number (S001, S002 ...). */
    private String nextStudentId() {
        int max = 0;
        for (User u : repo.findAll()) {
            String uid = u.getId();
            if (uid != null && uid.matches("(?i)S\\d{1,9}")) max = Math.max(max, Integer.parseInt(uid.substring(1)));
        }
        String id;
        do { id = String.format("S%03d", ++max); } while (repo.findById(id).isPresent());
        return id;
    }

    // =================== LOGIN ===================

    /** Login with Student ID or email. Updates the last-login time. */
    public User login(String idOrEmail, String password) throws AuthException {
        String key = Validator.clean(idOrEmail);
        Optional<User> found = key.contains("@") ? repo.findByEmail(key) : repo.findById(key);
        User u = found.orElseThrow(() -> new AuthException("Invalid ID/email or password."));
        if (!PasswordUtil.verify(password, u.getPasswordHash()))
            throw new AuthException("Invalid ID/email or password.");
        if (!u.isActive())
            throw new AuthException("Your account is inactive. Please contact the administrator.");
        u.setLastLogin(LocalDateTime.now().withNano(0));
        repo.update(u);
        return u;
    }

    // =================== READ ===================

    public Optional<User> findById(String id) { return repo.findById(id); }

    public List<User> findAll() { return repo.findAll(); }

    /** Search by ID / name / email, filter by status, sort and paginate (for the admin list). */
    public Page<User> search(String q, String status, String sort, int page, int pageSize) {
        return search(q, status, "ALL", sort, page, pageSize);
    }

    public Page<User> search(String q, String status, String level, String sort, int page, int pageSize) {
        String query = q == null ? "" : q.trim().toLowerCase();
        List<User> list = repo.findAll().stream()
            .filter(u -> !u.canManageUsers())                       // list students only
            .filter(u -> query.isEmpty()
                    || u.getId().toLowerCase().contains(query)
                    || u.getName().toLowerCase().contains(query)
                    || u.getEmail().toLowerCase().contains(query))
            .filter(u -> status == null || status.isBlank() || "ALL".equalsIgnoreCase(status)
                    || u.getStatus() == AccountStatus.fromString(status))
            .filter(u -> level == null || level.isBlank() || "ALL".equalsIgnoreCase(level)
                    || u.getLevel() == StudentLevel.fromString(level))
            .collect(Collectors.toList());

        Comparator<User> cmp;
        switch (sort == null ? "" : sort) {
            case "name":   cmp = Comparator.comparing(u -> u.getName().toLowerCase()); break;
            case "email":  cmp = Comparator.comparing(u -> u.getEmail().toLowerCase()); break;
            case "newest": cmp = Comparator.comparing(User::getRegisteredDate).reversed(); break;
            default:       cmp = Comparator.comparing(u -> u.getId().toLowerCase());
        }
        list.sort(cmp);

        int total = list.size();
        int pages = Math.max(1, (int) Math.ceil(total / (double) pageSize));
        int p = Math.min(Math.max(page, 1), pages);
        int from = (p - 1) * pageSize;
        return new Page<>(list.subList(from, Math.min(from + pageSize, total)), p, pageSize, total);
    }

    /** Numbers for the admin dashboard. */
    public Map<String, Integer> statistics() {
        List<User> students = repo.findAll().stream().filter(u -> !u.canManageUsers()).collect(Collectors.toList());
        Map<String, Integer> m = new LinkedHashMap<>();
        m.put("total", students.size());
        m.put("active", (int) students.stream().filter(User::isActive).count());
        m.put("inactive", (int) students.stream().filter(u -> !u.isActive()).count());
        m.put("premium", (int) students.stream().filter(u -> "PREMIUM".equals(u.getType())).count());
        for (StudentLevel l : StudentLevel.values())
            m.put(l.name().toLowerCase(), (int) students.stream().filter(u -> u.getLevel() == l).count());
        m.put("newThisMonth", (int) students.stream()
            .filter(u -> u.getRegisteredDate().getYear() == LocalDate.now().getYear()
                      && u.getRegisteredDate().getMonth() == LocalDate.now().getMonth()).count());
        return m;
    }

    /** CSV text of all students (admin export). */
    public String exportCsv() {
        StringBuilder sb = new StringBuilder("Student ID,Name,Email,Phone,Membership,Level,Status,Registered,Last Login\n");
        for (User u : repo.findAll()) {
            if (u.canManageUsers()) continue;
            Student s = (Student) u;
            sb.append(csv(u.getId())).append(',').append(csv(u.getName())).append(',')
              .append(csv(u.getEmail())).append(',').append(csv(u.getPhone())).append(',')
              .append(csv(s.getMembershipLabel())).append(',').append(csv(u.getLevelDisplay())).append(',')
              .append(u.getStatus()).append(',')
              .append(u.getRegisteredDate()).append(',')
              .append(u.getLastLogin() == null ? "" : u.getLastLoginText()).append('\n');
        }
        return sb.toString();
    }

    private static String csv(String v) {
        String s = v == null ? "" : v;
        // prefix to stop spreadsheet formula injection
        if (!s.isEmpty() && "=+-@".indexOf(s.charAt(0)) >= 0) s = "'" + s;
        return "\"" + s.replace("\"", "\"\"") + "\"";
    }

    // =================== UPDATE ===================

    /** Student edits his/her own profile. */
    public void updateProfile(User u, String name, String email, String phone, String dob, String address,
                              String levelDetail) throws ValidationException {
        name = Validator.clean(name); email = Validator.clean(email);
        phone = Validator.clean(phone); dob = Validator.clean(dob); address = Validator.clean(address);
        levelDetail = Validator.clean(levelDetail);

        List<String> errors = new ArrayList<>();
        if (!u.canManageUsers() && !u.getLevel().isValidDetail(levelDetail))
            errors.add("Please enter a valid value for: " + u.getLevel().getDetailLabel() + ".");
        if (!Validator.isValidName(name)) errors.add("Name must be 2-60 characters (letters, spaces, . ' - only).");
        if (!Validator.isValidEmail(email)) errors.add("Please enter a valid email address.");
        else {
            Optional<User> other = repo.findByEmail(email);
            if (other.isPresent() && !other.get().getId().equalsIgnoreCase(u.getId()))
                errors.add("This email is used by another account.");
        }
        if (!Validator.isValidPhone(phone)) errors.add("Phone number must be 9-15 digits (optional + at the start).");
        if (!Validator.isValidBirthDate(dob)) errors.add("Date of birth must be a valid past date.");
        if (!errors.isEmpty()) throw new ValidationException(errors);

        u.setName(name);
        u.setEmail(email);
        u.setPhone(phone);
        u.setAddress(address);
        u.setDateOfBirth(dob.isEmpty() ? null : LocalDate.parse(dob));
        if (!u.canManageUsers()) u.setLevelDetail(levelDetail);
        repo.update(u);
    }

    /** Admin edits a student: profile + status + membership type. */
    public User adminUpdate(String id, String name, String email, String phone, String dob, String address,
                            String status, boolean premium,
                            String levelCode, String levelDetail) throws ValidationException {
        User u = repo.findById(id).orElseThrow(() -> new ValidationException("Student not found."));
        StudentLevel level = StudentLevel.parse(levelCode);
        if (level == null) throw new ValidationException("Please choose the student's level.");
        u.setLevel(level);   // not saved unless everything below is valid
        updateProfile(u, name, email, phone, dob, address, levelDetail);
        u.setStatus(AccountStatus.fromString(status));
        if (!u.canManageUsers()) {
            // type change = create a new object of the other subclass with the same data
            User changed = UserFactory.create(premium ? "PREMIUM" : "STUDENT",
                    u.getId(), u.getName(), u.getEmail(), u.getPasswordHash());
            copyDetails(u, changed);
            repo.update(changed);
            return changed;
        }
        repo.update(u);
        return u;
    }

    /** A student paid for the Premium membership: switch the account to PREMIUM (same data, new subclass). */
    public User upgradeToPremium(String id) throws ValidationException {
        User u = repo.findById(id).orElseThrow(() -> new ValidationException("Student not found."));
        if (u.canManageUsers() || "PREMIUM".equals(u.getType())) return u;
        User changed = UserFactory.create("PREMIUM", u.getId(), u.getName(), u.getEmail(), u.getPasswordHash());
        copyDetails(u, changed);
        repo.update(changed);
        return changed;
    }

    private void copyDetails(User from, User to) {
        to.setPhone(from.getPhone());
        to.setDateOfBirth(from.getDateOfBirth());
        to.setAddress(from.getAddress());
        to.setStatus(from.getStatus());
        to.setRegisteredDate(from.getRegisteredDate());
        to.setLastLogin(from.getLastLogin());
        to.setProfilePicture(from.getProfilePicture());
        to.setSecurityQuestion(from.getSecurityQuestion());
        to.setSecurityAnswerHash(from.getSecurityAnswerHash());
        to.setLevel(from.getLevel());
        to.setLevelDetail(from.getLevelDetail());
    }

    public void changePassword(User u, String oldPw, String newPw, String confirm) throws ValidationException {
        List<String> errors = new ArrayList<>();
        if (!PasswordUtil.verify(oldPw, u.getPasswordHash())) errors.add("Current password is incorrect.");
        if (!Validator.isStrongPassword(newPw)) errors.add("New password must be 6-64 characters with at least one letter and one digit.");
        else if (!newPw.equals(confirm)) errors.add("New password and confirm password do not match.");
        else if (newPw.equals(oldPw)) errors.add("New password must be different from the current password.");
        if (!errors.isEmpty()) throw new ValidationException(errors);
        u.setPasswordHash(PasswordUtil.hash(newPw));
        repo.update(u);
    }

    public void setProfilePicture(User u, String fileName) {
        u.setProfilePicture(fileName);
        repo.update(u);
    }

    public void setStatus(String id, AccountStatus status) {
        repo.findById(id).ifPresent(u -> { u.setStatus(status); repo.update(u); });
    }


    /** Admin sets a new (temporary) password for a student. */
    public void adminResetPassword(String id, String newPw) throws ValidationException {
        User u = repo.findById(id).orElseThrow(() -> new ValidationException("Student not found."));
        if (!Validator.isStrongPassword(newPw))
            throw new ValidationException("New password must be 6-64 characters with at least one letter and one digit.");
        u.setPasswordHash(PasswordUtil.hash(newPw));
        repo.update(u);
    }

    // =================== FORGOT PASSWORD ===================

    /** Step 1: returns the security question of the account. */
    public String getSecurityQuestion(String id) throws ValidationException {
        User u = repo.findById(Validator.clean(id)).orElseThrow(() -> new ValidationException("No account found for that Student ID."));
        return u.getSecurityQuestion();
    }

    /** Step 2: checks the answer and sets a new password. */
    public void resetPassword(String id, String answer, String newPw, String confirm) throws ValidationException {
        User u = repo.findById(Validator.clean(id)).orElseThrow(() -> new ValidationException("No account found for that Student ID."));
        List<String> errors = new ArrayList<>();
        if (!PasswordUtil.verify(PasswordUtil.normalizeAnswer(answer), u.getSecurityAnswerHash()))
            errors.add("The answer to the security question is incorrect.");
        if (!Validator.isStrongPassword(newPw)) errors.add("New password must be 6-64 characters with at least one letter and one digit.");
        else if (!newPw.equals(confirm)) errors.add("New password and confirm password do not match.");
        if (!errors.isEmpty()) throw new ValidationException(errors);
        u.setPasswordHash(PasswordUtil.hash(newPw));
        repo.update(u);
    }

    // =================== DELETE ===================

    /** Admin deletes a student. */
    public boolean delete(String id) {
        boolean gone = repo.delete(id);
        if (gone) {   // the student's saved page data + rows in the readable tables go too
            try {
                com.lms.student.repository.AppDataRepository.getInstance().deleteOwner(id);
                com.lms.student.repository.DataMirror.getInstance().removeStudent(id);
            } catch (RuntimeException e) { System.err.println("Could not clean up data of " + id + ": " + e.getMessage()); }
        }
        return gone;
    }
}
