<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<%
    java.sql.Connection con = null;
    int totalPonds = 0;

    try {
        con = MysqlCon.getConnection();

        // Get total pond count
        Statement countStmt = con.createStatement();
        ResultSet countRs = countStmt.executeQuery("SELECT COUNT(*) AS total FROM ponds");
        if (countRs.next()) {
            totalPonds = countRs.getInt("total");
        }
        countRs.close();
        countStmt.close();
    } catch (Exception e) {
        // Connection failed 
    }
%>

    <header>
        <h1>Koi Pond Manager</h1>
        <nav>
            <a href="index.jsp">Dashboard</a>
            <a href="ponds.jsp">Ponds</a>
            <a href="koi.jsp">Koi</a>
            <a href="treatments.jsp">Treatments</a>
            <a href="logs.jsp">Logs</a>
        </nav>
        <div class="user-menu">
            <span class="user-name"><%= session.getAttribute("fullName") %></span>
            <span class="user-role"><%= session.getAttribute("role") %></span>
            <a href="logout" class="btn-logout">Sign Out</a>
        </div>
    </header>

    <main>
        <%-- Summary Cards --%>
        <div class="summary-cards">
            <div class="card">
                <div class="card-label">Total Ponds</div>
                <div class="card-value"><%= totalPonds %></div>
                <div class="card-sub"><a href="ponds.jsp">Manage ponds</a></div>
            </div>
            <div class="card">
                <div class="card-label">Koi Inventory</div>
                <div class="card-value">0</div>
                <div class="card-sub">Coming soon</div>
            </div>
            <div class="card">
                <div class="card-label">Water Quality</div>
                <div class="card-value">—</div>
                <div class="card-sub">Coming soon</div>
            </div>
            <div class="card">
                <div class="card-label">Open Tasks</div>
                <div class="card-value">0</div>
                <div class="card-sub">Coming soon</div>
            </div>
        </div>

        <%-- Pond Overview --%>
        <div class="section">
            <h2>Pond Overview</h2>
            <table>
                <thead>
                    <tr>
                        <th>Pond Name</th>
                        <th>Location</th>
                        <th>Volume</th>
                        <th>Filtration</th>
                        <th>UV Bulbs</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try {
                        if (con != null && !con.isClosed()) {
                            Statement stmt = con.createStatement();
                            ResultSet rs = stmt.executeQuery("SELECT * FROM ponds ORDER BY name");

                            boolean hasRows = false;
                            while (rs.next()) {
                                hasRows = true;
                %>
                    <tr>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("location") != null ? rs.getString("location") : "—" %></td>
                        <td><%= String.format("%,.0f", rs.getDouble("volume")) %> <%= rs.getString("volume_unit") %></td>
                        <td><%= rs.getString("filtration_type") != null ? rs.getString("filtration_type") : "—" %></td>
                        <td><%= rs.getInt("uv_bulb_count") %> @ <%= rs.getDouble("uv_bulb_wattage") %>W</td>
                    </tr>
                <%
                            }
                            rs.close();
                            stmt.close();

                            if (!hasRows) {
                %>
                    <tr>
                        <td colspan="5" style="text-align:center; color:#6c757d; padding:2rem;">
                            No ponds yet. <a href="ponds.jsp">Add your first pond</a>
                        </td>
                    </tr>
                <%
                            }
                        }
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="5" style="color:#dc3545;">Error loading ponds: <%= e.getMessage() %></td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

<%
    if (con != null) {
        try { con.close(); } catch (SQLException e) { /* ignore */ }
    }
%>

</body>
</html>
