<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.koi.MysqlCon" %>
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
    <title>Ponds - Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<%
    // Database connection
    java.sql.Connection con = null;
    String error = null;
    String success = null;

    try {
        con = MysqlCon.getConnection();

        // Handle form submissions
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String sql = "INSERT INTO ponds (name, location, volume, volume_unit, length, width, depth, "
                       + "filtration_type, uv_bulb_count, uv_bulb_wattage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, request.getParameter("name"));
            ps.setString(2, request.getParameter("location"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("volume")));
            ps.setString(4, request.getParameter("volumeUnit"));
            ps.setDouble(5, request.getParameter("length") != null && !request.getParameter("length").isEmpty() ? Double.parseDouble(request.getParameter("length")) : 0);
            ps.setDouble(6, request.getParameter("width") != null && !request.getParameter("width").isEmpty() ? Double.parseDouble(request.getParameter("width")) : 0);
            ps.setDouble(7, request.getParameter("depth") != null && !request.getParameter("depth").isEmpty() ? Double.parseDouble(request.getParameter("depth")) : 0);
            ps.setString(8, request.getParameter("filtrationType"));
            ps.setInt(9, request.getParameter("uvBulbCount") != null && !request.getParameter("uvBulbCount").isEmpty() ? Integer.parseInt(request.getParameter("uvBulbCount")) : 0);
            ps.setDouble(10, request.getParameter("uvBulbWattage") != null && !request.getParameter("uvBulbWattage").isEmpty() ? Double.parseDouble(request.getParameter("uvBulbWattage")) : 0);
            ps.executeUpdate();
            ps.close();
            success = "Pond created successfully.";

        } else if ("update".equals(action)) {
            String sql = "UPDATE ponds SET name=?, location=?, volume=?, volume_unit=?, length=?, width=?, "
                       + "depth=?, filtration_type=?, uv_bulb_count=?, uv_bulb_wattage=? WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, request.getParameter("name"));
            ps.setString(2, request.getParameter("location"));
            ps.setDouble(3, Double.parseDouble(request.getParameter("volume")));
            ps.setString(4, request.getParameter("volumeUnit"));
            ps.setDouble(5, request.getParameter("length") != null && !request.getParameter("length").isEmpty() ? Double.parseDouble(request.getParameter("length")) : 0);
            ps.setDouble(6, request.getParameter("width") != null && !request.getParameter("width").isEmpty() ? Double.parseDouble(request.getParameter("width")) : 0);
            ps.setDouble(7, request.getParameter("depth") != null && !request.getParameter("depth").isEmpty() ? Double.parseDouble(request.getParameter("depth")) : 0);
            ps.setString(8, request.getParameter("filtrationType"));
            ps.setInt(9, request.getParameter("uvBulbCount") != null && !request.getParameter("uvBulbCount").isEmpty() ? Integer.parseInt(request.getParameter("uvBulbCount")) : 0);
            ps.setDouble(10, request.getParameter("uvBulbWattage") != null && !request.getParameter("uvBulbWattage").isEmpty() ? Double.parseDouble(request.getParameter("uvBulbWattage")) : 0);
            ps.setInt(11, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            success = "Pond updated successfully.";

        } else if ("delete".equals(action)) {
            // Find the pond id and delete it
            PreparedStatement ps = con.prepareStatement("DELETE FROM ponds WHERE id = ?");
            ps.setInt(1, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            success = "Pond deleted.";
        }

    } catch (Exception e) {
        error = e.getMessage();
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
        <div class="page-header">
            <h2>Pond Management</h2>
            <button class="btn btn-primary" onclick="openModal('addModal')">+ Add Pond</button>
        </div>

        <% if (error != null) { %>
            <!-- future: show more detailed error  -->
            <div class="alert alert-danger"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <!--  -->
            <div class="alert alert-success"><%= success %></div>
        <% } %>

        <%-- Load and display all ponds --%>
        <%
            // check if there are ponds and don't show otherwise
            boolean hasPonds = false;
            ResultSet rs = null;
            Statement stmt = null;

            try {
                if (con != null && !con.isClosed()) {
                    stmt = con.createStatement();
                    rs = stmt.executeQuery("SELECT * FROM ponds ORDER BY name");

                    if (rs.isBeforeFirst()) {
                        hasPonds = true;
        --%>
        <div class="pond-grid">
            <%
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String name = rs.getString("name");
                            String location = rs.getString("location");
                            double volume = rs.getDouble("volume");
                            String volumeUnit = rs.getString("volume_unit");
                            double length = rs.getDouble("length");
                            double width = rs.getDouble("width");
                            double depth = rs.getDouble("depth");
                            String filtrationType = rs.getString("filtration_type");
                            int uvBulbCount = rs.getInt("uv_bulb_count");
                            double uvBulbWattage = rs.getDouble("uv_bulb_wattage");
            %>
            <div class="card pond-card">
                <div class="pond-card-header">
                    <h3><%= name %></h3>
                    <div class="pond-actions">
                        <button class="btn btn-sm btn-edit" onclick="openEditModal(<%= id %>,
                            '<%= name %>',
                            '<%= location != null ? location : "" %>',
                            <%= volume %>,
                            '<%= volumeUnit %>',
                            <%= length %>,
                            <%= width %>,
                            <%= depth %>,
                            '<%= filtrationType != null ? filtrationType : "" %>',
                            <%= uvBulbCount %>,
                            <%= uvBulbWattage %>)">Edit</button>
                        <form method="post" action="ponds.jsp" style="display:inline;"
                              onsubmit="return confirm('Delete this pond?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" class="btn btn-sm btn-danger-outline">Delete</button>
                        </form>
                    </div>
                </div>
                <div class="pond-details">
                    <div class="detail-row">
                        <span class="detail-label">Location</span>
                        <span class="detail-value"><%= location != null ? location : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Volume</span>
                        <span class="detail-value"><%= String.format("%,.0f", volume) %> <%= volumeUnit %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Dimensions (L x W x D)</span>
                        <span class="detail-value"><%= length %> x <%= width %> x <%= depth %> ft</span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Filtration</span>
                        <span class="detail-value"><%= filtrationType != null ? filtrationType : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">UV Bulbs</span>
                        <span class="detail-value"><%= uvBulbCount %> bulb(s) @ <%= uvBulbWattage %>W</span>
                    </div>
                </div>
            </div>
            <%
                        }
            %>
        </div>
        <%
                    }
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                }
            } catch (Exception e) {
        %>
            <div class="alert alert-danger">Error loading ponds: <%= e.getMessage() %></div>
        <%
            }

            if (!hasPonds) {
        %>
        <div class="section empty-state">
            <p>No ponds yet. Click <strong>+ Add Pond</strong> to create your first pond.</p>
        </div>
        <%
            }

            // Close connection
            if (con != null) {
                try { con.close(); } catch (SQLException e) { /* ignore */ }
            }
        %>
    </main>

    <%-- Add Pond Popup --%>
    <div id="addModal" class="modal-overlay" onclick="if(event.target===this)closeModal('addModal')">
        <div class="modal">
            <div class="modal-header">
                <h3>Add New Pond</h3>
                <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
            </div>
            <form method="post" action="ponds.jsp">
                <input type="hidden" name="action" value="create">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="add-name">Pond Name *</label>
                        <input type="text" id="add-name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="add-location">Location</label>
                        <input type="text" id="add-location" name="location" placeholder="e.g. Backyard north side">
                    </div>
                    <div class="form-group">
                        <label for="add-volume">Volume *</label>
                        <input type="number" id="add-volume" name="volume" step="0.1" required>
                    </div>
                    <div class="form-group">
                        <label for="add-volumeUnit">Unit</label>
                        <select id="add-volumeUnit" name="volumeUnit">
                            <option value="gallons">Gallons</option>
                            <option value="liters">Liters</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="add-length">Length (ft)</label>
                        <input type="number" id="add-length" name="length" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="add-width">Width (ft)</label>
                        <input type="number" id="add-width" name="width" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="add-depth">Depth (ft)</label>
                        <input type="number" id="add-depth" name="depth" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="add-filtrationType">Filtration Type</label>
                        <input type="text" id="add-filtrationType" name="filtrationType" placeholder="e.g. Bead filter, Drum filter">
                    </div>
                    <div class="form-group">
                        <label for="add-uvBulbCount">UV Bulb Count</label>
                        <input type="number" id="add-uvBulbCount" name="uvBulbCount" min="0" value="0">
                    </div>
                    <div class="form-group">
                        <label for="add-uvBulbWattage">UV Bulb Wattage</label>
                        <input type="number" id="add-uvBulbWattage" name="uvBulbWattage" step="0.1" min="0" value="0">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Pond</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Edit Pond Modal --%>
    <div id="editModal" class="modal-overlay" onclick="if(event.target===this)closeModal('editModal')">
        <div class="modal">
            <div class="modal-header">
                <h3>Edit Pond</h3>
                <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
            </div>
            <form method="post" action="ponds.jsp">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="edit-id" name="id">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="edit-name">Pond Name *</label>
                        <input type="text" id="edit-name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="edit-location">Location</label>
                        <input type="text" id="edit-location" name="location">
                    </div>
                    <div class="form-group">
                        <label for="edit-volume">Volume *</label>
                        <input type="number" id="edit-volume" name="volume" step="0.1" required>
                    </div>
                    <div class="form-group">
                        <label for="edit-volumeUnit">Unit</label>
                        <select id="edit-volumeUnit" name="volumeUnit">
                            <option value="gallons">Gallons</option>
                            <option value="liters">Liters</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="edit-length">Length (ft)</label>
                        <input type="number" id="edit-length" name="length" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="edit-width">Width (ft)</label>
                        <input type="number" id="edit-width" name="width" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="edit-depth">Depth (ft)</label>
                        <input type="number" id="edit-depth" name="depth" step="0.1">
                    </div>
                    <div class="form-group">
                        <label for="edit-filtrationType">Filtration Type</label>
                        <input type="text" id="edit-filtrationType" name="filtrationType">
                    </div>
                    <div class="form-group">
                        <label for="edit-uvBulbCount">UV Bulb Count</label>
                        <input type="number" id="edit-uvBulbCount" name="uvBulbCount" min="0">
                    </div>
                    <div class="form-group">
                        <label for="edit-uvBulbWattage">UV Bulb Wattage</label>
                        <input type="number" id="edit-uvBulbWattage" name="uvBulbWattage" step="0.1" min="0">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('editModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

    <script>
        function openModal(id) {
            document.getElementById(id).classList.add('active');
        }

        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }

        function openEditModal(id, name, location, volume, volumeUnit, length, width, depth, filtrationType, uvBulbCount, uvBulbWattage) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-location').value = location;
            document.getElementById('edit-volume').value = volume;
            document.getElementById('edit-volumeUnit').value = volumeUnit;
            document.getElementById('edit-length').value = length;
            document.getElementById('edit-width').value = width;
            document.getElementById('edit-depth').value = depth;
            document.getElementById('edit-filtrationType').value = filtrationType;
            document.getElementById('edit-uvBulbCount').value = uvBulbCount;
            document.getElementById('edit-uvBulbWattage').value = uvBulbWattage;
            openModal('editModal');
        }
    </script>

</body>
</html>
