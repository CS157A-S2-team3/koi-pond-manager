package com.koi;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/saveKoi")
// Allows for future image file uploads (Requirement 3.3.1)
//@MultipartConfig 
public class KoiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        // 1. Retrieve required fields
        String name = request.getParameter("name");
        String variety = request.getParameter("variety");
        
        // Handling optional numerical fields with defensive coding
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

        // FIX: The pond_id is likely not being passed correctly from the JSP.
        // For testing, we will default it to a valid 'Ponds.id' or handle null.
        // Replicating teammate's strategy.
        String pondIdRaw = request.getParameter("pond_id");
        Integer pondId = (pondIdRaw != null && !pondIdRaw.isEmpty()) ? Integer.parseInt(pondIdRaw) : 1;
        // In your production code, use standard connection handling

        Connection con = null;
        PreparedStatement ps = null;

        try {
            // Teammate's direct connection strategy for immediate testing
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/koipondmanager?useSSL=false&serverTimezone=UTC",
                "root", "kiqsi6-woznaq-Syzpan");
            
            // 2. SQL Insert based on Relational Schema
            String sql = "INSERT INTO Koi (name, age, variety, breeder, sex, size_cm, pond_id) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, name);
            
            // Set required but optional INT/DOUBLE fields to NULL if not provided
            if (age != null) ps.setInt(2, age); else ps.setNull(2, java.sql.Types.INTEGER);
            ps.setString(3, variety);
            ps.setString(4, breeder);
            ps.setString(5, sex);
            if (sizeCm != null) ps.setDouble(6, sizeCm); else ps.setNull(6, java.sql.Types.DOUBLE);
            
            // Setting a default Pond ID until the dynamic selector is active
            if (pondId != null) ps.setInt(7, pondId); else ps.setNull(7, java.sql.Types.INTEGER);

            int result = ps.executeUpdate();
            
            if (result > 0) {
                // Return success to the UI (matches blue theme success state)
                response.sendRedirect("koi.jsp?success=true");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("koiProfile.jsp?error=database");
        } finally {
            // Teammate's standard cleanup strategy
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}