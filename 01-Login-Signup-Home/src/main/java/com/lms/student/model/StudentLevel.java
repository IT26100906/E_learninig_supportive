package com.lms.student.model;

import java.util.List;

/**
 * The kind of learner a student is. Chosen at sign-up; each level gets its OWN look
 * (theme) and its OWN dashboard page.
 *
 * POLYMORPHISM: every constant has its own body that overrides greeting(), subjects(),
 * isValidDetail(), describe() and highlight(), so the same method call behaves
 * differently for Child, School, A/L and Undergraduate students.
 */
public enum StudentLevel {

    CHILD("Child", "\uD83E\uDDD2", "child", "dashboard-child", "Age", "Ages 3 - 7") {
        @Override public String greeting(String name) { return "Hello, " + name + "! \uD83C\uDF08"; }
        @Override public boolean isValidDetail(String d) { return inRange(d, 3, 7); }
        @Override public String describe(String d) { return blank(d) ? "Child" : "Age " + d; }
        @Override public String highlight(String d) { return ""; }
        @Override public List<Subject> subjects(String d) {
            return List.of(new Subject("\uD83D\uDCD6", "Stories"), new Subject("\uD83D\uDD22", "Numbers"),
                           new Subject("\uD83C\uDFA8", "Colours"), new Subject("\uD83C\uDFB5", "Songs"),
                           new Subject("\uD83D\uDC3C", "Animals"), new Subject("\uD83C\uDFAE", "Games"));
        }
    },

    SCHOOL("Grade 1 - 11", "\uD83C\uDF92", "school", "dashboard-school", "Grade", "School student") {
        @Override public String greeting(String name) { return "Welcome back, " + name + "! \uD83C\uDF92"; }
        @Override public boolean isValidDetail(String d) { return inRange(d, 1, 11); }
        @Override public String describe(String d) { return blank(d) ? "School student" : "Grade " + d; }
        @Override public String highlight(String d) {
            int g = toInt(d);
            if (g == 5) return "Scholarship exam year";
            if (g == 10 || g == 11) return "O/L preparation";
            return "";
        }
        @Override public List<Subject> subjects(String d) {
            int g = toInt(d);
            if (g <= 5) {
                return List.of(new Subject("\uD83D\uDDE3", "Mother Tongue"), new Subject("\uD83D\uDD24", "English"),
                               new Subject("\uD83E\uDDEE", "Mathematics"), new Subject("\uD83C\uDF33", "Environment"),
                               new Subject("\uD83D\uDE4F", "Religion"), new Subject("\uD83C\uDFA8", "Aesthetics"));
            }
            if (g <= 9) {
                return List.of(new Subject("\uD83D\uDDE3", "Mother Tongue"), new Subject("\uD83D\uDD24", "English"),
                               new Subject("\uD83E\uDDEE", "Mathematics"), new Subject("\uD83D\uDD2C", "Science"),
                               new Subject("\uD83C\uDFDB", "History"), new Subject("\uD83C\uDF0D", "Geography"),
                               new Subject("\uD83D\uDCBB", "ICT"), new Subject("\uD83C\uDF4E", "Health"));
            }
            return List.of(new Subject("\uD83D\uDDE3", "Mother Tongue"), new Subject("\uD83D\uDD24", "English"),
                           new Subject("\uD83E\uDDEE", "Mathematics"), new Subject("\uD83D\uDD2C", "Science"),
                           new Subject("\uD83C\uDFDB", "History"), new Subject("\uD83D\uDE4F", "Religion"),
                           new Subject("\uD83D\uDCD0", "Optional Subjects"));
        }
    },

    AL("A/L Student", "\uD83D\uDCDA", "al", "dashboard-al", "Stream", "Advanced Level") {
        @Override public String greeting(String name) { return "Stay focused, " + name + " \uD83C\uDFAF"; }
        @Override public boolean isValidDetail(String d) { return AL_STREAMS.contains(d); }
        @Override public String describe(String d) { return blank(d) ? "A/L Student" : "A/L - " + d; }
        @Override public String highlight(String d) { return "A/L exam focus"; }
        @Override public List<Subject> subjects(String d) {
            String s = d == null ? "" : d;
            if (s.startsWith("Physical")) {
                return List.of(new Subject("\uD83D\uDCD0", "Combined Mathematics"), new Subject("\u269B", "Physics"),
                               new Subject("\u2697", "Chemistry"), new Subject("\uD83D\uDD24", "General English"));
            }
            if (s.startsWith("Biological")) {
                return List.of(new Subject("\uD83E\uDDEC", "Biology"), new Subject("\u269B", "Physics"),
                               new Subject("\u2697", "Chemistry"), new Subject("\uD83D\uDD24", "General English"));
            }
            if (s.startsWith("Commerce")) {
                return List.of(new Subject("\uD83D\uDCB0", "Accounting"), new Subject("\uD83D\uDCCA", "Business Studies"),
                               new Subject("\uD83D\uDCC8", "Economics"), new Subject("\uD83D\uDD24", "General English"));
            }
            if (s.startsWith("Technology")) {
                return List.of(new Subject("\u2699", "Engineering Technology"), new Subject("\uD83D\uDD2C", "Science for Technology"),
                               new Subject("\uD83D\uDCBB", "ICT"), new Subject("\uD83D\uDD24", "General English"));
            }
            return List.of(new Subject("\uD83D\uDDF3", "Political Science"), new Subject("\uD83E\uDDE0", "Logic"),
                           new Subject("\uD83C\uDF0D", "Geography"), new Subject("\uD83D\uDD24", "General English"));
        }
    },

    UNDERGRAD("Undergraduate", "\uD83C\uDF93", "undergrad", "dashboard-undergrad", "Degree / Course", "University student") {
        @Override public String greeting(String name) { return "Welcome, " + name + "!"; }
        @Override public boolean isValidDetail(String d) {
            return d == null || (d.length() <= 60 && d.matches("[\\p{L}\\p{N} .,&()'/-]*"));
        }
        @Override public String describe(String d) { return blank(d) ? "Undergraduate" : d; }
        @Override public String highlight(String d) { return ""; }
        @Override public List<Subject> subjects(String d) { return List.of(); }
    };

    /** Streams a student can choose in A/L. */
    public static final List<String> AL_STREAMS = List.of(
        "Physical Science (Maths)", "Biological Science", "Commerce", "Arts", "Technology");

    /** Degrees offered in the sign-up dropdown (faculty -> degrees). Keep in sync with js/courses.js. */
    public static final java.util.Map<String, List<String>> UG_DEGREES = new java.util.LinkedHashMap<>();
    static {
        UG_DEGREES.put("Computing & IT", List.of("BSc (Hons) in Information Technology", "BSc (Hons) in Computer Science", "BSc (Hons) in Software Engineering", "BSc (Hons) in Data Science", "BSc (Hons) in Cyber Security", "BSc (Hons) in Information Systems"));
        UG_DEGREES.put("Business & Management", List.of("BSc in Business Management", "BBA in Accounting & Finance", "BSc in Marketing Management", "BSc in Human Resource Management", "BSc in Banking & Finance"));
        UG_DEGREES.put("Engineering & Built Environment", List.of("BSc Eng (Hons) in Civil Engineering", "BSc Eng (Hons) in Electrical & Electronic Engineering", "BSc Eng (Hons) in Mechanical Engineering", "BSc Eng (Hons) in Mechatronics Engineering", "BSc (Hons) in Quantity Surveying", "BSc (Hons) in Architecture"));
        UG_DEGREES.put("Science", List.of("BSc in Physical Science", "BSc in Biological Science", "BSc in Chemistry", "BSc in Mathematics", "BSc in Applied Statistics", "BSc in Biotechnology"));
        UG_DEGREES.put("Health Sciences", List.of("MBBS (Medicine)", "BSc in Nursing", "BPharm (Pharmacy)", "BSc in Medical Laboratory Sciences"));
        UG_DEGREES.put("Law, Arts & Education", List.of("LLB (Law)", "BA in English", "BA in Psychology", "BEd in Education", "BA in Mass Communication"));
    }

    /** One subject tile on a dashboard. */
    public static class Subject {
        private final String icon;
        private final String name;
        public Subject(String icon, String name) { this.icon = icon; this.name = name; }
        public String getIcon() { return icon; }
        public String getName() { return name; }
    }

    private final String label, icon, theme, dashboardView, detailLabel, tagline;

    StudentLevel(String label, String icon, String theme, String dashboardView, String detailLabel, String tagline) {
        this.label = label; this.icon = icon; this.theme = theme;
        this.dashboardView = dashboardView; this.detailLabel = detailLabel; this.tagline = tagline;
    }

    // ----- behaviour that differs for every level (polymorphism) -----
    public abstract String greeting(String name);
    public abstract boolean isValidDetail(String detail);
    public abstract String describe(String detail);
    public abstract String highlight(String detail);
    public abstract List<Subject> subjects(String detail);

    // ----- getters used by the JSP pages -----
    public String getCode() { return name(); }
    public String getLabel() { return label; }
    public String getIcon() { return icon; }
    public String getTheme() { return theme; }
    public String getDashboardView() { return dashboardView; }
    public String getDetailLabel() { return detailLabel; }
    public String getTagline() { return tagline; }

    // ----- helpers -----
    /** Returns the level for a code like "SCHOOL", or null if the code is not valid. */
    public static StudentLevel parse(String code) {
        try {
            return StudentLevel.valueOf(code == null ? "" : code.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    /** Same as parse() but falls back to UNDERGRAD (used when reading old data). */
    public static StudentLevel fromString(String code) {
        StudentLevel l = parse(code);
        return l == null ? UNDERGRAD : l;
    }

    /** True when the text is one of the degrees in the sign-up dropdown. */
    public static boolean isKnownDegree(String d) {
        for (List<String> list : UG_DEGREES.values()) if (list.contains(d)) return true;
        return false;
    }

    static boolean blank(String s) { return s == null || s.isBlank(); }

    static int toInt(String s) {
        try { return Integer.parseInt(s == null ? "" : s.trim()); } catch (NumberFormatException e) { return 1; }
    }

    static boolean inRange(String s, int min, int max) {
        try {
            int v = Integer.parseInt(s == null ? "" : s.trim());
            return v >= min && v <= max;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
