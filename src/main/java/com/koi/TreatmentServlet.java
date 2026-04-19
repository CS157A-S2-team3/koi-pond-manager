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

@WebServlet("/treatment")
public class TreatmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null;
        PreparedStatement ps = null;
        PreparedStatement pondPs = null;

        try {
            int pondId = Integer.parseInt(request.getParameter("pondId"));
            int userId = (int) request.getSession().getAttribute("userId");
            String medication = request.getParameter("medication");
            String purpose = request.getParameter("purpose");
            double dosage = Double.parseDouble(request.getParameter("dosage"));
            String dosageUnit = request.getParameter("dosageUnit");
            int duration = Integer.parseInt(request.getParameter("duration"));
            String pondVolumeText = request.getParameter("pondVolume");
            String notes = request.getParameter("notes");
            boolean quarantine = request.getParameter("quarantine") != null;

            if (pondId <= 0) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Please select a valid pond.", "UTF-8"));
                return;
            }

            if (medication == null || medication.trim().isEmpty()) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Medication is required.", "UTF-8"));
                return;
            }

            if (purpose == null || purpose.trim().isEmpty()) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Purpose is required.", "UTF-8"));
                return;
            }

            if (dosage < 0) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Dosage cannot be negative.", "UTF-8"));
                return;
            }

            if (duration <= 0) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Duration must be at least 1 day.", "UTF-8"));
                return;
            }

            if (pondVolumeText == null || pondVolumeText.trim().isEmpty()) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Pond volume is required.", "UTF-8"));
                return;
            }

            double pondVolume = Double.parseDouble(pondVolumeText);

            if (pondVolume <= 0) {
                response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Pond volume must be greater than 0.", "UTF-8"));
                return;
            }

            con = MysqlCon.getConnection();

            String sql = "INSERT INTO treatments "
                    + "(pond_id, user_id, medication, purpose, dosage, dosage_unit, duration, pond_volume, notes, quarantine) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setInt(1, pondId);
            ps.setInt(2, userId);
            ps.setString(3, medication);
            ps.setString(4, purpose);
            ps.setDouble(5, dosage);
            ps.setString(6, dosageUnit);
            ps.setInt(7, duration);
            ps.setDouble(8, pondVolume);
            ps.setString(9, notes);
            ps.setBoolean(10, quarantine);

            ps.executeUpdate();

            // ✅ IMPORTANT: quarantine updates pond status
            if (quarantine) {
                pondPs = con.prepareStatement("UPDATE ponds SET is_quarantine = ? WHERE id = ?");
                pondPs.setBoolean(1, true);
                pondPs.setInt(2, pondId);
                pondPs.executeUpdate();
            }

            response.sendRedirect("treatment.jsp?success=1");

        } catch (NumberFormatException e) {
            response.sendRedirect("treatment.jsp?error=" + URLEncoder.encode("Please enter valid numeric values.", "UTF-8"));
        } catch (Exception e) {
            throw new ServletException(e);
        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (pondPs != null) pondPs.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}


