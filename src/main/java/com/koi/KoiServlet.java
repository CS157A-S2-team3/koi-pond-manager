package com.koi;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/saveKoi")
public class KoiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        boolean isUpdate = (idParam != null && !idParam.isEmpty());
        int koiId = isUpdate ? Integer.parseInt(idParam) : -1;

        String name = request.getParameter("name");
        String variety = request.getParameter("variety");
        String breeder = request.getParameter("breeder");
        String sex = request.getParameter("sex");
        String status = request.getParameter("status");

        Integer age = null;
        if (request.getParameter("age") != null && !request.getParameter("age").isEmpty()) {
            age = Integer.parseInt(request.getParameter("age"));
        }

        Double sizeCm = null;
        if (request.getParameter("size_cm") != null && !request.getParameter("size_cm").isEmpty()) {
            sizeCm = Double.parseDouble(request.getParameter("size_cm"));
        }

        String pondIdRaw = request.getParameter("pond_id");
        Integer pondId = (pondIdRaw != null && !pondIdRaw.isEmpty()) ? Integer.parseInt(pondIdRaw) : null;
        String notes = request.getParameter("notes");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("orgId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        int orgId = (int) session.getAttribute("orgId");
        int userId = (int) session.getAttribute("userId");

        try (Connection con = MysqlCon.getConnection()) {
            // Validate pond exists
            if (pondId != null) {
                try (PreparedStatement check = con.prepareStatement("SELECT id FROM ponds WHERE id = ?")) {
                    check.setInt(1, pondId);
                    try (java.sql.ResultSet rs = check.executeQuery()) {
                        if (!rs.next()) pondId = null;
                    }
                }
            }

            if (isUpdate) {
                // Fetch previous pond_id to detect transfers
                Integer previousPondId = null;
                try (PreparedStatement fetch = con.prepareStatement("SELECT pond_id FROM koi WHERE id = ?")) {
                    fetch.setInt(1, koiId);
                    try (java.sql.ResultSet fetchRs = fetch.executeQuery()) {
                        if (fetchRs.next()) {
                            previousPondId = fetchRs.getInt("pond_id");
                            if (fetchRs.wasNull()) previousPondId = null;
                        }
                    }
                }

                String sql = "UPDATE koi SET name=?, age=?, variety=?, breeder=?, sex=?, size_cm=?, status=?, pond_id=?, notes=? WHERE id=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setString(1, name);
                    if (age != null) ps.setInt(2, age); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.setString(3, variety);
                    ps.setString(4, breeder);
                    ps.setString(5, sex);
                    if (sizeCm != null) ps.setDouble(6, sizeCm); else ps.setNull(6, java.sql.Types.DOUBLE);
                    ps.setString(7, status != null ? status : "healthy");
                    if (pondId != null) ps.setInt(8, pondId); else ps.setNull(8, java.sql.Types.INTEGER);
                    ps.setString(9, notes);
                    ps.setInt(10, koiId);
                    ps.executeUpdate();
                }

                // Record pond transfer if pond_id changed
                boolean pondChanged = (previousPondId == null && pondId != null)
                                   || (previousPondId != null && !previousPondId.equals(pondId));
                if (pondChanged) {
                    String histSql = "INSERT INTO koi_pond_history (koi_id, from_pond_id, to_pond_id, moved_by, notes) VALUES (?, ?, ?, ?, 'transferred')";
                    try (PreparedStatement hp = con.prepareStatement(histSql)) {
                        hp.setInt(1, koiId);
                        if (previousPondId != null) hp.setInt(2, previousPondId); else hp.setNull(2, java.sql.Types.INTEGER);
                        if (pondId != null) hp.setInt(3, pondId); else hp.setNull(3, java.sql.Types.INTEGER);
                        hp.setInt(4, userId);
                        hp.executeUpdate();
                    }
                }

            } else {
                String sql = "INSERT INTO koi (organization_id, name, age, variety, breeder, sex, size_cm, status, pond_id, notes) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, orgId);
                    ps.setString(2, name);
                    if (age != null) ps.setInt(3, age); else ps.setNull(3, java.sql.Types.INTEGER);
                    ps.setString(4, variety);
                    ps.setString(5, breeder);
                    ps.setString(6, sex);
                    if (sizeCm != null) ps.setDouble(7, sizeCm); else ps.setNull(7, java.sql.Types.DOUBLE);
                    ps.setString(8, status != null ? status : "healthy");
                    if (pondId != null) ps.setInt(9, pondId); else ps.setNull(9, java.sql.Types.INTEGER);
                    ps.setString(10, notes);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect("koi.jsp?success=true");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("koiProfile.jsp?error=database");
        }
    }
}