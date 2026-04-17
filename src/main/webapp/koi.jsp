<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Koi Inventory Management - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/koi-inventory.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    
    <header>
        <h1>Koi Pond Manager</h1>
        <nav>
            <a href="index.jsp">Dashboard</a>
            <a href="ponds.jsp">Ponds</a>
            <a href="koi.jsp">Koi</a>
            <a href="treatments.jsp">Treatments</a>
            <a href="logs.jsp">Logs</a>
        </nav>
    </header>

    <main class="content-wrapper">
    	<div class="container">
        	<header class="inventory-header">
            	<h2>Koi Inventory</h2>
            	<a href="koiProfile.jsp" class="add-task-btn" style="text-decoration: none;">
                	<i class="fa fa-plus"></i> Create New Koi Profile
            	</a>
        	</header>

        	<div class="koi-grid-centered">
                <%
                    // Dynamic Database Connection 
                    java.sql.Connection con = null;
                    try {
                        con = MysqlCon.getConnection();

                        Statement stmt = con.createStatement();
                        // Query to get all koi profiles 
                        ResultSet rs = stmt.executeQuery("SELECT * FROM koi ORDER BY created_at DESC");

                        boolean hasKoi = false;
                        while (rs.next()) {
                            hasKoi = true;
                            // Retrieve data for each koi 
                            int id = rs.getInt("id");
                            String name = rs.getString("name");
                            String variety = rs.getString("variety");
                            String breeder = rs.getString("breeder");
                            double size = rs.getDouble("size_cm");
                %>
                    <%-- DYNAMIC KOI CARD --%>
                    <div class="koi-card-horizontal">
                        <div class="koi-details-left">
                            <div class="koi-info">
                                <h3><%= name %> (ID: <%= id %>)</h3>
                                <p><strong>Variety:</strong> <%= variety %></p>
                                <p><strong>Breeder:</strong> <%= (breeder != null) ? breeder : "N/A" %></p>
                                <p><strong>Size:</strong> <%= String.format("%.2f", size) %> cm</p>
                            </div>
                            <div class="koi-card-actions">
                                <a href="koiProfile.jsp?id=<%= id %>" class="action-btn" style="text-decoration: none;">Update Profile</a>
                            </div>
                        </div>
                        <div class="koi-image-right">
                            <%-- Standard placeholder for now (Requirement 3.3.1) --%>
                            <img src="https://via.placeholder.com/200x200.png?text=<%= variety %>" alt="Koi ID <%= id %>">
                        </div>
                    </div>
                <%
                        }
                        
                        // Empty State handling (if no koi are in the database yet)
                        if (!hasKoi) {
                %>
                    <div class="empty-state" style="text-align: center; padding: 50px; color: #666;">
                        <p>No koi profiles found. Click "Create New Koi Profile" to get started!</p>
                    </div>
                <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error loading inventory: " + e.getMessage() + "</p>");
                    } finally {
                        if (con != null) try { con.close(); } catch (SQLException e) {}
                    }
                %>
            </div>
    	</div>
	</main>
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>