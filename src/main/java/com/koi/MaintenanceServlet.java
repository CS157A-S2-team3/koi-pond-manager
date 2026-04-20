package com.koi;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/saveSchedule")
public class MaintenanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String notes = request.getParameter("notes");
        String freq = request.getParameter("freq");
        String dueAt = request.getParameter("due_at");
        int userId = (int) session.getAttribute("userId");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet generatedKeys = null;

        try {
            con = MysqlCon.getConnection();
            
            // 1. Insert the Recurring Schedule
            String sql = "INSERT INTO MaintenanceSchedule (notes, freq, user_id) VALUES (?, ?, ?)";
            ps = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
            ps.setString(1, notes);
            ps.setString(2, freq);
            ps.setInt(3, userId);
            
            int affectedRows = ps.executeUpdate();
            
            if (affectedRows > 0) {
                generatedKeys = ps.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int scheduleId = generatedKeys.getInt(1);
                    
                    // 2. Generate the first task based on the start date
                    String taskSql = "INSERT INTO MaintenanceTask (schedule_id, due_at, status, notes) VALUES (?, ?, 'Pending', ?)";
                    PreparedStatement taskPs = con.prepareStatement(taskSql);
                    taskPs.setInt(1, scheduleId);
                    taskPs.setDate(2, Date.valueOf(dueAt));
                    taskPs.setString(3, notes);
                    taskPs.executeUpdate();
                    taskPs.close();
                }
                response.sendRedirect("maintenance.jsp?success=true");
            } else {
                response.sendRedirect("maintenance.jsp?error=database");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("maintenance.jsp?error=database");
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}