package com.lms.student.service;

/** Student enrollments and the admin's shared enrollment settings. */
public final class CourseEnrollmentService {
    public static final String ADMIN_KEY = "adm-enr";
    private final ModuleDataService data;
    public CourseEnrollmentService() { this(new ModuleDataService()); }
    public CourseEnrollmentService(ModuleDataService data) { this.data = data; }
    public String getStudentData(String studentId, String key) { return data.readFor(studentId).get(key); }
    public void saveStudentData(String studentId, String key, String json) { data.save(studentId, key, json); }
    public String getAdminData() { return data.readShared().get(ADMIN_KEY); }
    public void saveAdminData(String json) { data.save("*", ADMIN_KEY, json); }
}
