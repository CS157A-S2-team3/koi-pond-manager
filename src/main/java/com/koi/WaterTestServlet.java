package com.koi;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/waterTest")
public class WaterTestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;

        try {
            int pondId = Integer.parseInt(request.getParameter("pondId"));
            int userId = 1; // temporary fallback user ID for now

            double ph = Double.parseDouble(request.getParameter("ph"));
            double temperature = Double.parseDouble(request.getParameter("temperature"));
            double ammonia = Double.parseDouble(request.getParameter("ammonia"));
            double nitrite = Double.parseDouble(request.getParameter("nitrite"));
            double nitrate = Double.parseDouble(request.getParameter("nitrate"));
            String notes = request.getParameter("notes");

            if (pondId <= 0) {
                response.sendRedirect("waterTest.jsp?error=" +
                        URLEncoder.encode("Please select a valid pond.", "UTF-8"));
                return;
            }

            if (ph < 0 || ph > 14) {
                response.sendRedirect("waterTest.jsp?error=" +
                        URLEncoder.encode("pH must be between 0 and 14.", "UTF-8"));
                return;
            }

            if (temperature < 32 || temperature > 120) {
                response.sendRedirect("waterTest.jsp?error=" +
                        URLEncoder.encode("Temperature must be between 32 and 120.", "UTF-8"));
                return;
            }

            if (ammonia < 0 || nitrite < 0 || nitrate < 0) {
                response.sendRedirect("waterTest.jsp?error=" +
                        URLEncoder.encode("Ammonia, nitrite, and nitrate cannot be negative.", "UTF-8"));
                return;
            }

            StringBuilder warning = new StringBuilder();

            if (ph < 6.5 || ph > 8.5) {
                warning.append("pH is outside the recommended range (6.5-8.5). ");
            }
            if (ammonia >= 0.25) {
                warning.append("Ammonia is above the recommended threshold (< 0.25). ");
            }
            if (nitrite >= 0.25) {
                warning.append("Nitrite is above the recommended threshold (< 0.25). ");
            }
            if (nitrate >= 40) {
                warning.append("Nitrate is above the recommended threshold (< 40). ");
            }
            if (temperature < 50 || temperature > 85) {
                warning.append("Temperature is outside the typical koi-safe range (50-85°F). ");
            }

            con = MysqlCon.getConnection();

            String sql = "INSERT INTO water_tests "
                    + "(pond_id, user_id, ph, temperature, ammonia, nitrite, nitrate, notes) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1, pondId);
            ps.setInt(2, userId);
            ps.setDouble(3, ph);
            ps.setDouble(4, temperature);
            ps.setDouble(5, ammonia);
            ps.setDouble(6, nitrite);
            ps.setDouble(7, nitrate);
            ps.setString(8, notes);

            ps.executeUpdate();

            if (warning.length() > 0) {
                response.sendRedirect("waterTest.jsp?success=1&warning=" +
                        URLEncoder.encode(warning.toString(), "UTF-8"));
            } else {
                response.sendRedirect("waterTest.jsp?success=1");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("waterTest.jsp?error=" +
                    URLEncoder.encode("Please enter valid numeric values.", "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("waterTest.jsp?error=" +
                    URLEncoder.encode("Database error while saving water test.", "UTF-8"));
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (Exception e) {
            }

            try {
                if (con != null) con.close();
            } catch (Exception e) {
            }
        }
    }
}
