package com.koi;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Reads environment variables, with fallback to a .env file. Lookup order:
//   1. process environment (System.getenv)  — wins, so 12-factor deployments work
//   2. -Dkoi.env.file=<path>                — explicit override
//   3. ~/.koi-pond-manager.env              — user-home location, deploy-friendly
//   4. ./.env                               — only useful if Tomcat is launched from project root
public class EnvLoader {
    private static final Map<String, String> CACHE = new HashMap<>();
    private static boolean loaded = false;

    public static synchronized String get(String key) {
        if (!loaded) load();
        String envVal = System.getenv(key);
        if (envVal != null && !envVal.isEmpty()) return envVal;
        return CACHE.get(key);
    }

    public static String require(String key) {
        String v = get(key);
        if (v == null || v.isEmpty()) {
            throw new IllegalStateException(
                "Required env var '" + key + "' is not set. Set it in the OS environment, " +
                "in ~/.koi-pond-manager.env, or pass -Dkoi.env.file=/path/to/.env to Tomcat. " +
                "See .env.example for the expected variables.");
        }
        return v;
    }

    private static synchronized void load() {
        if (loaded) return;
        loaded = true;

        List<Path> candidates = new ArrayList<>();
        String sysProp = System.getProperty("koi.env.file");
        if (sysProp != null && !sysProp.isEmpty()) candidates.add(Path.of(sysProp));
        candidates.add(Path.of(System.getProperty("user.home"), ".koi-pond-manager.env"));
        candidates.add(Path.of(System.getProperty("user.dir"), ".env"));

        for (Path p : candidates) {
            if (Files.isRegularFile(p)) {
                try {
                    parseInto(p, CACHE);
                    return;
                } catch (IOException ignored) {
                    // try the next candidate
                }
            }
        }
    }

    private static void parseInto(Path p, Map<String, String> into) throws IOException {
        for (String raw : Files.readAllLines(p, StandardCharsets.UTF_8)) {
            String line = raw.trim();
            if (line.isEmpty() || line.startsWith("#")) continue;
            int eq = line.indexOf('=');
            if (eq < 0) continue;
            String k = line.substring(0, eq).trim();
            String v = line.substring(eq + 1).trim();
            if (v.length() >= 2
                && ((v.startsWith("\"") && v.endsWith("\"")) || (v.startsWith("'") && v.endsWith("'")))) {
                v = v.substring(1, v.length() - 1);
            }
            into.put(k, v);
        }
    }
}
