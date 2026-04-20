package com.koi;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.InputStream;

@WebServlet("/saveKoi")
@MultipartConfig(maxFileSize = 16177215) // up to 16MB
public class KoiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if this is an update or insert
        String idParam = request.getParameter("id");
        boolean isUpdate = (idParam != null && !idParam.isEmpty());
        int koiId = isUpdate ? Integer.parseInt(idParam) : -1;

        String name = request.getParameter("name");
        String variety = request.getParameter("variety");
        
        Integer age = null;
        if (request.getParameter("age") != null && !request.getParameter("age").isEmpty()) {
            age = Integer.parseInt(request.getParameter("age"));
        }

        Double sizeCm = null;
        if (request.getParameter("size_cm") != null && !request.getParameter("size_cm").isEmpty()) {
            sizeCm = Double.parseDouble(request.getParameter("size_cm"));
        }

        String sex = request.getParameter("sex");
        String breeder = request.getParameter("breeder");

        String pondIdRaw = request.getParameter("pond_id");
        Integer pondId = (pondIdRaw != null && !pondIdRaw.isEmpty()) ? Integer.parseInt(pondIdRaw) : null;

        // Image extraction
        InputStream imageInputStream = null;
        Part filePart = request.getPart("koi_image");
        if (filePart != null && filePart.getSize() > 0) {
            imageInputStream = filePart.getInputStream();
        }

        try (Connection con = MysqlCon.getConnection()) {
            // Validate pond exists
            if (pondId != null) {
                try (PreparedStatement check = con.prepareStatement("SELECT id FROM ponds WHERE id = ?")) {
                    check.setInt(1, pondId);
                    try (java.sql.ResultSet rs = check.executeQuery()) {
                        if (!rs.next()) {
                            pondId = null;
                        }
                    }
                }
            }

            if (isUpdate) {
                // UPDATE existing koi
                String sql;
                PreparedStatement ps;
                
                if (imageInputStream != null) {
                    sql = "UPDATE koi SET name=?, age=?, variety=?, breeder=?, sex=?, size_cm=?, pond_id=?, image_data=? WHERE id=?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, name);
                    if (age != null) ps.setInt(2, age); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.setString(3, variety);
                    ps.setString(4, breeder);
                    ps.setString(5, sex);
                    if (sizeCm != null) ps.setDouble(6, sizeCm); else ps.setNull(6, java.sql.Types.DOUBLE);
                    if (pondId != null) ps.setInt(7, pondId); else ps.setNull(7, java.sql.Types.INTEGER);
                    ps.setBlob(8, imageInputStream);
                    ps.setInt(9, koiId);
                } else {
                    sql = "UPDATE koi SET name=?, age=?, variety=?, breeder=?, sex=?, size_cm=?, pond_id=? WHERE id=?";
                    ps = con.prepareStatement(sql);
                    ps.setString(1, name);
                    if (age != null) ps.setInt(2, age); else ps.setNull(2, java.sql.Types.INTEGER);
                    ps.setString(3, variety);
                    ps.setString(4, breeder);
                    ps.setString(5, sex);
                    if (sizeCm != null) ps.setDouble(6, sizeCm); else ps.setNull(6, java.sql.Types.DOUBLE);
                    if (pondId != null) ps.setInt(7, pondId); else ps.setNull(7, java.sql.Types.INTEGER);
                    ps.setInt(8, koiId);
                }
                
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("koi.jsp?success=true");
                
            } else {
                // INSERT new koi
                String sql = "INSERT INTO koi (name, age, variety, breeder, sex, size_cm, pond_id, image_data) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, name);
                if (age != null) ps.setInt(2, age); else ps.setNull(2, java.sql.Types.INTEGER);
                ps.setString(3, variety);
                ps.setString(4, breeder);
                ps.setString(5, sex);
                if (sizeCm != null) ps.setDouble(6, sizeCm); else ps.setNull(6, java.sql.Types.DOUBLE);
                if (pondId != null) ps.setInt(7, pondId); else ps.setNull(7, java.sql.Types.INTEGER);
                if (imageInputStream != null) {
                    ps.setBlob(8, imageInputStream);
                } else {
                    ps.setNull(8, java.sql.Types.BLOB);
                }
                ps.executeUpdate();
                ps.close();
                response.sendRedirect("koi.jsp?success=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("koiProfile.jsp?error=database");
        }
    }
}