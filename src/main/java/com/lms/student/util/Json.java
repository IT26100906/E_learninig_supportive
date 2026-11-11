package com.lms.student.util;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Very small JSON reader (no external library needed).
 * parse() returns: Map (object), List (array), String, Double (number), Boolean or null.
 * Helper methods str / num / bool / list / map read values safely and never throw.
 */
public final class Json {

    private final String s;
    private int i;

    private Json(String s) { this.s = s; }

    /** Parses JSON text; returns null if the text is empty or not valid JSON. */
    public static Object parse(String text) {
        if (text == null) return null;
        try {
            Json p = new Json(text);
            p.ws();
            Object v = p.value();
            p.ws();
            return p.i == p.s.length() ? v : null;
        } catch (RuntimeException e) {
            return null;
        }
    }

    // ---------------------------------------------------------------- safe readers

    public static String str(Object o, String key) {
        Object v = o instanceof Map ? ((Map<?, ?>) o).get(key) : null;
        if (v == null) return "";
        if (v instanceof Double) {
            double d = (Double) v;
            return d == Math.rint(d) && Math.abs(d) < 1e15 ? String.valueOf((long) d) : String.valueOf(d);
        }
        return String.valueOf(v);
    }

    public static double num(Object o, String key, double def) {
        Object v = o instanceof Map ? ((Map<?, ?>) o).get(key) : null;
        if (v instanceof Double) return (Double) v;
        if (v instanceof String) { try { return Double.parseDouble(((String) v).trim()); } catch (NumberFormatException ignored) { } }
        return def;
    }

    public static int intval(Object o, String key, int def) { return (int) Math.round(num(o, key, def)); }

    public static Object raw(Object o, String key) { return o instanceof Map ? ((Map<?, ?>) o).get(key) : null; }

    public static List<?> list(Object o) { return o instanceof List ? (List<?>) o : new ArrayList<>(); }

    // ---------------------------------------------------------------- parser

    private void ws() { while (i < s.length() && Character.isWhitespace(s.charAt(i))) i++; }

    private Object value() {
        char c = s.charAt(i);
        if (c == '{') return object();
        if (c == '[') return array();
        if (c == '"') return string();
        if (s.startsWith("true", i)) { i += 4; return Boolean.TRUE; }
        if (s.startsWith("false", i)) { i += 5; return Boolean.FALSE; }
        if (s.startsWith("null", i)) { i += 4; return null; }
        return number();
    }

    private Map<String, Object> object() {
        Map<String, Object> m = new LinkedHashMap<>();
        i++; ws();
        if (s.charAt(i) == '}') { i++; return m; }
        while (true) {
            ws();
            String k = string();
            ws(); expect(':'); ws();
            m.put(k, value());
            ws();
            if (s.charAt(i) == ',') { i++; continue; }
            expect('}');
            return m;
        }
    }

    private List<Object> array() {
        List<Object> l = new ArrayList<>();
        i++; ws();
        if (s.charAt(i) == ']') { i++; return l; }
        while (true) {
            ws();
            l.add(value());
            ws();
            if (s.charAt(i) == ',') { i++; continue; }
            expect(']');
            return l;
        }
    }

    private String string() {
        expect('"');
        StringBuilder sb = new StringBuilder();
        while (true) {
            char c = s.charAt(i++);
            if (c == '"') return sb.toString();
            if (c != '\\') { sb.append(c); continue; }
            char e = s.charAt(i++);
            switch (e) {
                case 'n': sb.append('\n'); break;
                case 't': sb.append('\t'); break;
                case 'r': sb.append('\r'); break;
                case 'b': sb.append('\b'); break;
                case 'f': sb.append('\f'); break;
                case 'u': sb.append((char) Integer.parseInt(s.substring(i, i + 4), 16)); i += 4; break;
                default: sb.append(e);   // \" \\ \/
            }
        }
    }

    private Double number() {
        int st = i;
        while (i < s.length() && "+-0123456789.eE".indexOf(s.charAt(i)) >= 0) i++;
        if (st == i) throw new IllegalArgumentException("bad json");
        return Double.valueOf(s.substring(st, i));
    }

    private void expect(char c) {
        if (s.charAt(i) != c) throw new IllegalArgumentException("expected " + c);
        i++;
    }
}
