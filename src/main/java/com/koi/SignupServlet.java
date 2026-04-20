package com.koi;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String orgName = request.getParameter("orgName");
        String timezone = request.getParameter("timezone");
        String useType = request.getParameter("useType");
        String unitPreference = request.getParameter("unitPreference");
        String stockingDensity = request.getParameter("stockingDensity");

        // Validation
        if (fullName == null || fullName.trim().isEmpty()
                || email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()
                || orgName == null || orgName.trim().isEmpty()) {
            redirect(response, request, "signup.jsp", "All required fields must be filled.");
            return;
        }

        if (password.length() < 8) {
            redirect(response, request, "signup.jsp", "Password must be at least 8 characters.");
            return;
        }

        if (!password.equals(confirmPassword)) {
            redirect(response, request, "signup.jsp", "Passwords do not match.");
            return;
        }

        Connection con = null;
        try {
            con = MysqlCon.getConnection();
            con.setAutoCommit(false);

            // Check if email already exists
            PreparedStatement checkStmt = con.prepareStatement(
                    "SELECT id FROM users WHERE email = ?");
            checkStmt.setString(1, email.trim());
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                rs.close();
                checkStmt.close();
                redirect(response, request, "signup.jsp", "An account with that email already exists.");
                return;
            }
            rs.close();
            checkStmt.close();

            // Create organization
            PreparedStatement orgStmt = con.prepareStatement(
                    "INSERT INTO organizations (name, timezone, use_type, unit_preference, stocking_density) VALUES (?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            orgStmt.setString(1, orgName.trim());
            orgStmt.setString(2, timezone != null ? timezone.trim() : "UTC");
            orgStmt.setString(3, useType != null ? useType : "hobbyist");
            orgStmt.setString(4, unitPreference != null ? unitPreference : "imperial");
            orgStmt.setString(5, stockingDensity != null ? stockingDensity : "standard");
            orgStmt.executeUpdate();

            ResultSet orgKeys = orgStmt.getGeneratedKeys();
            orgKeys.next();
            int orgId = orgKeys.getInt(1);
            orgKeys.close();
            orgStmt.close();

            // Create admin user
            String passwordHash = PasswordUtil.hashPassword(password);
            PreparedStatement userStmt = con.prepareStatement(
                    "INSERT INTO users (full_name, email, password_hash, role, organization_id) VALUES (?, ?, ?, 'admin', ?)",
                    Statement.RETURN_GENERATED_KEYS);
            userStmt.setString(1, fullName.trim());
            userStmt.setString(2, email.trim());
            userStmt.setString(3, passwordHash);
            userStmt.setInt(4, orgId);
            userStmt.executeUpdate();

            ResultSet userKeys = userStmt.getGeneratedKeys();
            userKeys.next();
            int userId = userKeys.getInt(1);
            userKeys.close();
            userStmt.close();

            con.commit();

            // Log the user in
            HttpSession session = request.getSession(true);
            session.setAttribute("userId", userId);
            session.setAttribute("fullName", fullName.trim());
            session.setAttribute("email", email.trim());
            session.setAttribute("role", "admin");
            session.setAttribute("orgId", orgId);
            session.setAttribute("orgName", orgName.trim());

            response.sendRedirect(request.getContextPath() + "/index.jsp");

        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            redirect(response, request, "signup.jsp", "Registration failed: " + e.getMessage());
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException e) { /* ignore */ }
            }
        }
    }

    private void redirect(HttpServletResponse response, HttpServletRequest request,
                          String page, String error) throws IOException {
        response.sendRedirect(request.getContextPath() + "/" + page
                + "?error=" + URLEncoder.encode(error, "UTF-8"));
    }
}
