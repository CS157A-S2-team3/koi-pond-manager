package com.koi;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection con = MysqlCon.getConnection()) {
            // Find the user by email
            PreparedStatement stmt = con.prepareStatement(
                    "SELECT u.id, u.full_name, u.password_hash, u.role, u.organization_id, o.name AS org_name "
                    + "FROM users u JOIN organizations o ON u.organization_id = o.id "
                    + "WHERE u.email = ?");
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            // If user is found and password hash matches
            if (rs.next() && PasswordUtil.verifyPassword(password, rs.getString("password_hash"))) {
                // Validate the session
                HttpSession session = request.getSession(true);
                // Set the user attributes for the session
                session.setAttribute("userId", rs.getInt("id"));
                session.setAttribute("fullName", rs.getString("full_name"));
                session.setAttribute("role", rs.getString("role"));
                session.setAttribute("orgId", rs.getInt("organization_id"));
                session.setAttribute("orgName", rs.getString("org_name"));
                response.sendRedirect(request.getContextPath() + "/index.jsp");
                return;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Redirect to login with invalid login error
        response.sendRedirect(request.getContextPath() + "/login.jsp?error=Invalid+email+or+password");
    }
}
