package com.koi;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/deleteKoi")
public class DeleteKoiServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int koiId = Integer.parseInt(request.getParameter("id"));

        Connection con = null;
        try {
            con = MysqlCon.getConnection();
            PreparedStatement ps = con.prepareStatement("DELETE FROM koi WHERE id = ?");
            ps.setInt(1, koiId);
            ps.executeUpdate();
            ps.close();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (con != null) try { con.close(); } catch (Exception e) {}
        }

        response.sendRedirect("koi.jsp");
    }
}
