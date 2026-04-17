package com.koi;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/saveSchedule")
public class MaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Retrieve parameters from maintenance.jsp modal
        String notes = request.getParameter("notes");
        String freq = request.getParameter("freq");
        String dueAt = request.getParameter("due_at");
        
        // Placeholder for the logged-in user (Requirement 3.1)
        int createdByUserId = 1; 

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = MysqlCon.getConnection();
            
            // 2. Insert the Recurring Schedule (Requirement 3.5.1)
            String sql = "INSERT INTO MaintenanceSchedule (notes, freq, created_by_user_id) VALUES (?, ?, ?)";
            
            ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setString(1, notes);
            ps.setString(2, freq);
            ps.setInt(3, createdByUserId);
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                // Return to maintenance page on success
                response.sendRedirect("maintenance.jsp?success=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("maintenance.jsp?error=database");
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}