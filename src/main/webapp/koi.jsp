<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon, java.io.*, java.util.Base64" %>
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
                    java.sql.Connection con = null;
                    try {
                        con = MysqlCon.getConnection();
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM koi ORDER BY created_at DESC");

                        boolean hasKoi = false;
                        while (rs.next()) {
                            hasKoi = true;
                            int id = rs.getInt("id");
                            String name = rs.getString("name");
                            String variety = rs.getString("variety");
                            String breeder = rs.getString("breeder");
                            String sex = rs.getString("sex");
                            int age = rs.getInt("age");
                            boolean ageNull = rs.wasNull();
                            double size = rs.getDouble("size_cm");
                            boolean sizeNull = rs.wasNull();
                            int pondId = rs.getInt("pond_id");
                            boolean pondNull = rs.wasNull();
                            
                            Blob imageBlob = rs.getBlob("image_data");
                            String base64Image = null;
                            if (imageBlob != null) {
                                InputStream inputStream = imageBlob.getBinaryStream();
                                ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
                                byte[] buffer = new byte[4096];
                                int bytesRead = -1;
                                while ((bytesRead = inputStream.read(buffer)) != -1) {
                                    outputStream.write(buffer, 0, bytesRead);
                                }
                                byte[] imageBytes = outputStream.toByteArray();
                                base64Image = Base64.getEncoder().encodeToString(imageBytes);
                                inputStream.close();
                                outputStream.close();
                            }
                %>
                    <div class="koi-card-horizontal" onclick="openKoiModal('<%= name.replace("'", "\\'") %>', '<%= variety != null ? variety.replace("'", "\\'") : "N/A" %>', '<%= breeder != null ? breeder.replace("'", "\\'") : "N/A" %>', '<%= sex != null ? sex : "N/A" %>', '<%= ageNull ? "N/A" : age %>', '<%= sizeNull ? "N/A" : String.format("%.2f", size) + " cm" %>', '<%= pondNull ? "None" : pondId %>')" style="cursor:pointer;">
                        <div class="koi-details-left">
                            <div class="koi-info">
                                <h3><%= name %></h3>
                            </div>
                            <div class="koi-card-actions">
                                <a href="koiProfile.jsp?id=<%= id %>" class="action-btn" style="text-decoration: none;" onclick="event.stopPropagation();">Update Information</a>
                            </div>
                        </div>
                        <div class="koi-dot-menu" onclick="event.stopPropagation();">
                            <button class="dot-btn" onclick="toggleKoiMenu(event, this)">&#8942;</button>
                            <div class="koi-dropdown-menu">
                                <form action="deleteKoi" method="POST" onsubmit="return confirm('Are you sure you want to delete this koi?');">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="dropdown-item delete-item">Delete</button>
                                </form>
                            </div>
                        </div>
                        <div class="koi-image-right">
                            <% if (base64Image != null) { %>
                                <img src="data:image/jpeg;base64,<%= base64Image %>" alt="<%= name %>">
                            <% } else { %>
                                <img src="https://via.placeholder.com/200x200.png?text=<%= variety %>" alt="<%= name %>">
                            <% } %>
                        </div>
                    </div>
                <%
                        }
                        
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

    <!-- Koi Detail Modal -->
    <div id="koiModal" class="koi-modal-overlay" onclick="closeKoiModal(event)">
        <div class="koi-modal-content" onclick="event.stopPropagation()">
            <span class="koi-modal-close" onclick="closeKoiModal()">&times;</span>
            <h2 id="koiModalName"></h2>
            <div class="koi-modal-details">
                <p><strong>Variety:</strong> <span id="koiModalVariety"></span></p>
                <p><strong>Breeder:</strong> <span id="koiModalBreeder"></span></p>
                <p><strong>Sex:</strong> <span id="koiModalSex"></span></p>
                <p><strong>Age:</strong> <span id="koiModalAge"></span></p>
                <p><strong>Size:</strong> <span id="koiModalSize"></span></p>
                <p><strong>Pond ID:</strong> <span id="koiModalPond"></span></p>
            </div>
        </div>
    </div>

    <script>
        function openKoiModal(name, variety, breeder, sex, age, size, pond) {
            document.getElementById('koiModalName').textContent = name;
            document.getElementById('koiModalVariety').textContent = variety;
            document.getElementById('koiModalBreeder').textContent = breeder;
            document.getElementById('koiModalSex').textContent = sex;
            document.getElementById('koiModalAge').textContent = age;
            document.getElementById('koiModalSize').textContent = size;
            document.getElementById('koiModalPond').textContent = pond;
            document.getElementById('koiModal').style.display = 'flex';
        }
        function closeKoiModal(event) {
            if (!event || event.target === document.getElementById('koiModal')) {
                document.getElementById('koiModal').style.display = 'none';
            }
        }
        function toggleKoiMenu(e, btn) {
            e.stopPropagation();
            document.querySelectorAll('.koi-dropdown-menu.show').forEach(function(menu) {
                if (menu !== btn.nextElementSibling) menu.classList.remove('show');
            });
            btn.nextElementSibling.classList.toggle('show');
        }
        document.addEventListener('click', function(e) {
            if (!e.target.classList.contains('dot-btn')) {
                document.querySelectorAll('.koi-dropdown-menu.show').forEach(function(menu) {
                    menu.classList.remove('show');
                });
            }
        });
    </script>
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>
