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

@WebServlet("/completeTask")
public class CompleteTaskServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));
        String dueAt = request.getParameter("due_at");
        int userId = (int) session.getAttribute("userId");

        Connection con = null;
        try {
            con = MysqlCon.getConnection();

            // 1. Mark current task as Completed
            String updateSql = "UPDATE MaintenanceTask SET status = 'Completed', completed_at = NOW(), completed_by_user_id = ? " +
                               "WHERE schedule_id = ? AND due_at = ?";
            PreparedStatement ps = con.prepareStatement(updateSql);
            ps.setInt(1, userId);
            ps.setInt(2, scheduleId);
            ps.setDate(3, Date.valueOf(dueAt));
            ps.executeUpdate();
            ps.close();

            // 2. Generate the next task based on frequency
            String freqSql = "SELECT freq, notes FROM MaintenanceSchedule WHERE id = ?";
            PreparedStatement freqPs = con.prepareStatement(freqSql);
            freqPs.setInt(1, scheduleId);
            ResultSet rs = freqPs.executeQuery();

            if (rs.next()) {
                String freq = rs.getString("freq");
                String notes = rs.getString("notes");
                LocalDate currentDue = LocalDate.parse(dueAt);
                LocalDate nextDue;

                switch (freq) {
                    case "Daily":
                        nextDue = currentDue.plusDays(1);
                        break;
                    case "Weekly":
                        nextDue = currentDue.plusWeeks(1);
                        break;
                    case "Biweekly":
                        nextDue = currentDue.plusWeeks(2);
                        break;
                    case "Monthly":
                        nextDue = currentDue.plusMonths(1);
                        break;
                    default:
                        nextDue = currentDue.plusWeeks(1);
                }

                String insertSql = "INSERT INTO MaintenanceTask (schedule_id, due_at, status, notes) VALUES (?, ?, 'Pending', ?)";
                PreparedStatement insertPs = con.prepareStatement(insertSql);
                insertPs.setInt(1, scheduleId);
                insertPs.setDate(2, Date.valueOf(nextDue));
                insertPs.setString(3, notes);
                insertPs.executeUpdate();
                insertPs.close();
            }

            rs.close();
            freqPs.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (Exception e) {}
        }

        response.sendRedirect("maintenance.jsp");
    }
}
