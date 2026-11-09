package com.lms.student.util;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.regex.Pattern;

/** Server-side validation rules (the browser checks are NOT trusted). */
public final class Validator {

    private static final Pattern ID = Pattern.compile("^[A-Za-z][A-Za-z0-9]{2,11}$");
    private static final Pattern NAME = Pattern.compile("^[\\p{L} .'-]{2,60}$");
    private static final Pattern EMAIL = Pattern.compile("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE = Pattern.compile("^\\+?[0-9]{9,15}$");

    private Validator() { }

    public static boolean isValidId(String s)    { return s != null && ID.matcher(s).matches(); }
    public static boolean isValidName(String s)  { return s != null && NAME.matcher(s.trim()).matches(); }
    public static boolean isValidEmail(String s) { return s != null && s.length() <= 100 && EMAIL.matcher(s).matches(); }
    public static boolean isValidPhone(String s) { return s == null || s.isBlank() || PHONE.matcher(s).matches(); }

    /** At least 6 characters, with at least one letter and one digit. */
    public static boolean isStrongPassword(String s) {
        if (s == null || s.length() < 6 || s.length() > 64) return false;
        boolean letter = false, digit = false;
        for (char c : s.toCharArray()) {
            if (Character.isLetter(c)) letter = true;
            if (Character.isDigit(c)) digit = true;
        }
        return letter && digit;
    }

    /** Blank is allowed (optional field). Otherwise must be a past date in yyyy-MM-dd. */
    public static boolean isValidBirthDate(String s) {
        if (s == null || s.isBlank()) return true;
        try {
            LocalDate d = LocalDate.parse(s.trim());
            return d.isBefore(LocalDate.now()) && d.isAfter(LocalDate.now().minusYears(120));
        } catch (DateTimeParseException e) {
            return false;
        }
    }

    /** Removes characters that would break the '|' separated text file. */
    public static String clean(String s) {
        return s == null ? "" : s.replaceAll("[|\\r\\n\\t]", " ").trim();
    }
}
