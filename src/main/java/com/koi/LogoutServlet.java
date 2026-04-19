package com.koi;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        // Invalidate the current session
        request.getSession().invalidate();
        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
