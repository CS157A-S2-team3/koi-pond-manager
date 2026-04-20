package com.koi;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/deactivateSchedule")
public class DeactivateScheduleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));

        Connection con = null;
        try {
            con = MysqlCon.getConnection();

            // 1. Mark schedule as Inactive and set completed_at
            String updateSchedule = "UPDATE MaintenanceSchedule SET status = 'Inactive', completed_at = NOW() WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(updateSchedule);
            ps.setInt(1, scheduleId);
            ps.executeUpdate();
            ps.close();

            // 2. Remove all pending tasks for this schedule
            String deleteTasks = "DELETE FROM MaintenanceTask WHERE schedule_id = ? AND status = 'Pending'";
            PreparedStatement deletePs = con.prepareStatement(deleteTasks);
            deletePs.setInt(1, scheduleId);
            deletePs.executeUpdate();
            deletePs.close();

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (Exception e) {}
        }

        response.sendRedirect("maintenance.jsp");
    }
}
