package com.koi;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Minimal recursive-descent JSON parser. Returned values:
//   object -> Map<String, Object>
//   array  -> List<Object>
//   string -> String
//   number -> Long (integral) or Double (fractional/exponential)
//   bool   -> Boolean
//   null   -> null
public class JsonParser {
    private final String src;
    private int pos = 0;

    private JsonParser(String src) { this.src = src; }

    public static Object parse(String json) {
        JsonParser p = new JsonParser(json);
        p.skipWs();
        Object v = p.readValue();
        p.skipWs();
        if (p.pos < p.src.length()) {
            throw new RuntimeException("Trailing characters at offset " + p.pos);
        }
        return v;
    }

    private Object readValue() {
        skipWs();
        if (pos >= src.length()) throw new RuntimeException("Unexpected end of input");
        char c = src.charAt(pos);
        if (c == '{') return readObject();
        if (c == '[') return readArray();
        if (c == '"') return readString();
        if (c == 't' || c == 'f') return readBoolean();
        if (c == 'n') { expect("null"); return null; }
        return readNumber();
    }

    private Map<String, Object> readObject() {
        expect("{");
        Map<String, Object> m = new LinkedHashMap<>();
        skipWs();
        if (peek() == '}') { pos++; return m; }
        while (true) {
            skipWs();
            String k = readString();
            skipWs();
            expect(":");
            Object v = readValue();
            m.put(k, v);
            skipWs();
            char c = src.charAt(pos++);
            if (c == '}') return m;
            if (c != ',') throw new RuntimeException("Expected ',' or '}' at offset " + (pos - 1));
        }
    }

    private List<Object> readArray() {
        expect("[");
        List<Object> l = new ArrayList<>();
        skipWs();
        if (peek() == ']') { pos++; return l; }
        while (true) {
            l.add(readValue());
            skipWs();
            char c = src.charAt(pos++);
            if (c == ']') return l;
            if (c != ',') throw new RuntimeException("Expected ',' or ']' at offset " + (pos - 1));
        }
    }

    private String readString() {
        expect("\"");
        StringBuilder sb = new StringBuilder();
        while (pos < src.length()) {
            char c = src.charAt(pos++);
            if (c == '"') return sb.toString();
            if (c == '\\') {
                if (pos >= src.length()) throw new RuntimeException("Bad escape at end of input");
                char esc = src.charAt(pos++);
                switch (esc) {
                    case '"':  sb.append('"');  break;
                    case '\\': sb.append('\\'); break;
                    case '/':  sb.append('/');  break;
                    case 'b':  sb.append('\b'); break;
                    case 'f':  sb.append('\f'); break;
                    case 'n':  sb.append('\n'); break;
                    case 'r':  sb.append('\r'); break;
                    case 't':  sb.append('\t'); break;
                    case 'u':
                        if (pos + 4 > src.length()) throw new RuntimeException("Bad \\u escape");
                        int code = Integer.parseInt(src.substring(pos, pos + 4), 16);
                        sb.append((char) code);
                        pos += 4;
                        break;
                    default: throw new RuntimeException("Bad escape: \\" + esc);
                }
            } else {
                sb.append(c);
            }
        }
        throw new RuntimeException("Unterminated string");
    }

    private Number readNumber() {
        int start = pos;
        if (peek() == '-') pos++;
        while (pos < src.length()) {
            char c = src.charAt(pos);
            if (Character.isDigit(c) || c == '.' || c == 'e' || c == 'E' || c == '+' || c == '-') {
                pos++;
            } else break;
        }
        String n = src.substring(start, pos);
        if (n.contains(".") || n.contains("e") || n.contains("E")) return Double.parseDouble(n);
        return Long.parseLong(n);
    }

    private Boolean readBoolean() {
        if (src.startsWith("true", pos))  { pos += 4; return Boolean.TRUE; }
        if (src.startsWith("false", pos)) { pos += 5; return Boolean.FALSE; }
        throw new RuntimeException("Bad boolean literal at offset " + pos);
    }

    private void skipWs() {
        while (pos < src.length() && Character.isWhitespace(src.charAt(pos))) pos++;
    }

    private char peek() { return src.charAt(pos); }

    private void expect(String s) {
        if (!src.startsWith(s, pos)) {
            throw new RuntimeException("Expected '" + s + "' at offset " + pos);
        }
        pos += s.length();
    }
}
