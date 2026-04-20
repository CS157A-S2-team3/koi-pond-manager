<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon" %>
<%
    // Check if editing existing koi
    String koiIdParam = request.getParameter("id");
    int koiId = -1;
    String existingName = "";
    String existingVariety = "";
    String existingBreeder = "";
    String existingSex = "Unknown";
    String existingAge = "";
    String existingSize = "";
    int existingPondId = -1;
    
    if (koiIdParam != null && !koiIdParam.isEmpty()) {
        koiId = Integer.parseInt(koiIdParam);
        Connection con = null;
        try {
            con = MysqlCon.getConnection();
            PreparedStatement ps = con.prepareStatement("SELECT * FROM koi WHERE id = ?");
            ps.setInt(1, koiId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                existingName = rs.getString("name") != null ? rs.getString("name") : "";
                existingVariety = rs.getString("variety") != null ? rs.getString("variety") : "";
                existingBreeder = rs.getString("breeder") != null ? rs.getString("breeder") : "";
                existingSex = rs.getString("sex") != null ? rs.getString("sex") : "Unknown";
                int age = rs.getInt("age");
                existingAge = rs.wasNull() ? "" : String.valueOf(age);
                double size = rs.getDouble("size_cm");
                existingSize = rs.wasNull() ? "" : String.valueOf(size);
                existingPondId = rs.getInt("pond_id");
                if (rs.wasNull()) existingPondId = -1;
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            // ignore
        } finally {
            if (con != null) try { con.close(); } catch (Exception e) {}
        }
    }
    boolean isEdit = (koiId > 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title><%= isEdit ? "Update" : "Create" %> Koi Profile - Koi Pond Manager</title>
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
    	<div class="profile-centered-wrapper">
        	<div class="red-form-box">
            	<h2><%= isEdit ? "Update Koi Profile" : "Koi Profile Details" %></h2>
            	<form action="saveKoi" method="POST" enctype="multipart/form-data" class="koi-form">
            	    <% if (isEdit) { %>
            	        <input type="hidden" name="id" value="<%= koiId %>">
            	    <% } %>
                	<div class="form-group">
                    	<label>Koi Image</label>
                    	<input type="file" name="koi_image" accept="image/*" class="black-border-input">
                    	<% if (isEdit) { %>
                    	    <p style="font-size:0.85rem; color:#666; margin-top:4px;">Leave blank to keep current image.</p>
                    	<% } %>
                	</div>
                
                	<div class="form-group">
                    	<label>Koi Name</label>
                    	<input type="text" name="name" placeholder="e.g., Sakura" value="<%= existingName %>" required>
                	</div>

                	<div class="form-row">
                    	<div class="form-group">
                        	<label>Variety</label>
                        	<input type="text" name="variety" placeholder="e.g., Kohaku" value="<%= existingVariety %>" required>
                    	</div>
                    	<div class="form-group">
                        	<label>Breeder</label>
                        	<input type="text" name="breeder" placeholder="e.g., Dainichi" value="<%= existingBreeder %>">
                    	</div>
                	</div>

                	<div class="form-row">
                    	<div class="form-group">
                        	<label>Age (Years)</label>
                        	<input type="number" name="age" value="<%= existingAge %>">
                    	</div>
                    	<div class="form-group">
                        	<label>Sex</label>
                        	<select name="sex">
                            	<option value="Male" <%= "Male".equals(existingSex) ? "selected" : "" %>>Male</option>
                            	<option value="Female" <%= "Female".equals(existingSex) ? "selected" : "" %>>Female</option>
                            	<option value="Unknown" <%= "Unknown".equals(existingSex) ? "selected" : "" %>>Unknown</option>
                        	</select>
                    	</div>
                	</div>

                	<div class="form-group">
                    	<label>Size (cm)</label>
                    	<input type="number" step="0.01" name="size_cm" value="<%= existingSize %>" required>
                	</div>
                	
                	<div class="form-row-koi">
    					<div class="form-group-spaced">
        					<label class="koi-label">Assigned Pond</label>
        					<select name="pond_id" class="black-border-input">
            					<option value="" <%= (existingPondId == -1) ? "selected" : "" %>>None</option>
            					<%
            					    Connection pondCon = null;
            					    try {
            					        pondCon = MysqlCon.getConnection();
            					        Statement pondStmt = pondCon.createStatement();
            					        ResultSet pondRs = pondStmt.executeQuery("SELECT id, name FROM ponds ORDER BY name");
            					        while (pondRs.next()) {
            					            int pid = pondRs.getInt("id");
            					            String pname = pondRs.getString("name");
            					%>
            					<option value="<%= pid %>" <%= (existingPondId == pid) ? "selected" : "" %>><%= pname %></option>
            					<%
            					        }
            					        pondRs.close();
            					        pondStmt.close();
            					    } catch (Exception e) { }
            					    finally { if (pondCon != null) try { pondCon.close(); } catch (Exception e) {} }
            					%>
        					</select>
    					</div>
					</div>

                	<div class="form-actions">
                    	<button type="submit" class="add-task-btn"><%= isEdit ? "Update Profile" : "Save Profile" %></button>
                    	<a href="koi.jsp" class="cancel-link">Cancel</a>
                	</div>
            	</form>
        	</div>
    	</div>
	</main>
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>