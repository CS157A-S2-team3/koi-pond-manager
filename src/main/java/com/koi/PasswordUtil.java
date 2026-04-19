package com.koi;

public class PasswordUtil {

    public static String hashPassword(String password) {
        return Integer.toHexString(password.hashCode());
    }

    public static boolean verifyPassword(String password, String storedHash) {
        return hashPassword(password).equals(storedHash);
    }
}
