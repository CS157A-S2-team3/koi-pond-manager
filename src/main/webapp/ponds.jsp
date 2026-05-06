<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.koi.MysqlCon" %>
<%!
    private String lookupLocationPrefix(java.sql.Connection con, int locationId, int orgId) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(
                "SELECT prefix FROM pond_locations WHERE id = ? AND organization_id = ?")) {
            ps.setInt(1, locationId);
            ps.setInt(2, orgId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("prefix") : null;
            }
        }
    }
%>
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
            String code = request.getParameter("code") != null ? request.getParameter("code").trim().toUpperCase() : "";
            int locationId = Integer.parseInt(request.getParameter("locationId"));
            String prefix = lookupLocationPrefix(con, locationId, (Integer) session.getAttribute("orgId"));
            if (prefix != null && !prefix.isEmpty() && !code.startsWith(prefix)) {
                error = "Pond code '" + code + "' must start with the location's prefix '" + prefix + "'.";
            } else {
            String sql = "INSERT INTO ponds (organization_id, code, name, location_id, volume, volume_unit, "
                       + "length, width, depth, filtration_type, uv_bulb_count, uv_bulb_wattage) "
                       + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, (Integer) session.getAttribute("orgId"));
            ps.setString(2, code);
            String nameParam = request.getParameter("name");
            if (nameParam != null && !nameParam.isEmpty()) ps.setString(3, nameParam); else ps.setNull(3, java.sql.Types.VARCHAR);
            ps.setInt(4, locationId);
            String volParam = request.getParameter("volume");
            if (volParam != null && !volParam.isEmpty()) ps.setDouble(5, Double.parseDouble(volParam)); else ps.setNull(5, java.sql.Types.DOUBLE);
            ps.setString(6, request.getParameter("volumeUnit"));
            ps.setDouble(7, request.getParameter("length") != null && !request.getParameter("length").isEmpty() ? Double.parseDouble(request.getParameter("length")) : 0);
            ps.setDouble(8, request.getParameter("width") != null && !request.getParameter("width").isEmpty() ? Double.parseDouble(request.getParameter("width")) : 0);
            ps.setDouble(9, request.getParameter("depth") != null && !request.getParameter("depth").isEmpty() ? Double.parseDouble(request.getParameter("depth")) : 0);
            ps.setString(10, request.getParameter("filtrationType"));
            ps.setInt(11, request.getParameter("uvBulbCount") != null && !request.getParameter("uvBulbCount").isEmpty() ? Integer.parseInt(request.getParameter("uvBulbCount")) : 0);
            ps.setDouble(12, request.getParameter("uvBulbWattage") != null && !request.getParameter("uvBulbWattage").isEmpty() ? Double.parseDouble(request.getParameter("uvBulbWattage")) : 0);
            ps.executeUpdate();
            ps.close();
            success = "Pond created successfully.";
            }

        } else if ("update".equals(action)) {
            String code = request.getParameter("code") != null ? request.getParameter("code").trim().toUpperCase() : "";
            int locationId = Integer.parseInt(request.getParameter("locationId"));
            String prefix = lookupLocationPrefix(con, locationId, (Integer) session.getAttribute("orgId"));
            if (prefix != null && !prefix.isEmpty() && !code.startsWith(prefix)) {
                error = "Pond code '" + code + "' must start with the location's prefix '" + prefix + "'.";
            } else {
            String sql = "UPDATE ponds SET code=?, name=?, location_id=?, volume=?, volume_unit=?, length=?, width=?, "
                       + "depth=?, filtration_type=?, uv_bulb_count=?, uv_bulb_wattage=? WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, code);
            String nameParam = request.getParameter("name");
            if (nameParam != null && !nameParam.isEmpty()) ps.setString(2, nameParam); else ps.setNull(2, java.sql.Types.VARCHAR);
            ps.setInt(3, locationId);
            String volParam = request.getParameter("volume");
            if (volParam != null && !volParam.isEmpty()) ps.setDouble(4, Double.parseDouble(volParam)); else ps.setNull(4, java.sql.Types.DOUBLE);
            ps.setString(5, request.getParameter("volumeUnit"));
            ps.setDouble(6, request.getParameter("length") != null && !request.getParameter("length").isEmpty() ? Double.parseDouble(request.getParameter("length")) : 0);
            ps.setDouble(7, request.getParameter("width") != null && !request.getParameter("width").isEmpty() ? Double.parseDouble(request.getParameter("width")) : 0);
            ps.setDouble(8, request.getParameter("depth") != null && !request.getParameter("depth").isEmpty() ? Double.parseDouble(request.getParameter("depth")) : 0);
            ps.setString(9, request.getParameter("filtrationType"));
            ps.setInt(10, request.getParameter("uvBulbCount") != null && !request.getParameter("uvBulbCount").isEmpty() ? Integer.parseInt(request.getParameter("uvBulbCount")) : 0);
            ps.setDouble(11, request.getParameter("uvBulbWattage") != null && !request.getParameter("uvBulbWattage").isEmpty() ? Double.parseDouble(request.getParameter("uvBulbWattage")) : 0);
            ps.setInt(12, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
            ps.close();
            success = "Pond updated successfully.";
            }

        } else if ("delete".equals(action)) {
            int pondId = Integer.parseInt(request.getParameter("id"));
            // Check if any koi are assigned to this pond
            PreparedStatement koiCheck = con.prepareStatement("SELECT COUNT(*) AS cnt FROM koi WHERE pond_id = ?");
            koiCheck.setInt(1, pondId);
            ResultSet koiRs = koiCheck.executeQuery();
            koiRs.next();
            int koiCount = koiRs.getInt("cnt");
            koiRs.close();
            koiCheck.close();

            if (koiCount > 0) {
                error = "Cannot delete pond with " + koiCount + " koi assigned. Reassign them first.";
            } else {
                PreparedStatement ps = con.prepareStatement("DELETE FROM ponds WHERE id = ? AND organization_id = ?");
                ps.setInt(1, pondId);
                ps.setInt(2, (Integer) session.getAttribute("orgId"));
                ps.executeUpdate();
                ps.close();
                success = "Pond deleted.";
            }

        } else if ("createLocation".equals(action)) {
            int orgId = (Integer) session.getAttribute("orgId");
            PreparedStatement ordStmt = con.prepareStatement(
                "SELECT COALESCE(MAX(display_order), 0) + 1 AS next_order FROM pond_locations WHERE organization_id = ?");
            ordStmt.setInt(1, orgId);
            ResultSet ordRs = ordStmt.executeQuery();
            ordRs.next();
            int nextOrder = ordRs.getInt("next_order");
            ordRs.close();
            ordStmt.close();

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO pond_locations (organization_id, name, prefix, display_order) VALUES (?, ?, ?, ?)");
            ps.setInt(1, orgId);
            ps.setString(2, request.getParameter("locName").trim());
            String pfxParam = request.getParameter("locPrefix");
            ps.setString(3, pfxParam != null ? pfxParam.trim().toUpperCase() : "");
            ps.setInt(4, nextOrder);
            ps.executeUpdate();
            ps.close();
            success = "Location created.";
        }

    } catch (Exception e) {
        String msg = e.getMessage();
        if (msg != null && msg.contains("uniq_org_code")) {
            String attempted = request.getParameter("code");
            attempted = attempted != null ? attempted.trim().toUpperCase() : "";
            error = "A pond with code '" + attempted + "' already exists. Pick a different code.";
        } else if (msg != null && msg.contains("uniq_org_location")) {
            String attempted = request.getParameter("locName");
            attempted = attempted != null ? attempted.trim() : "";
            error = "A location named '" + attempted + "' already exists.";
        } else {
            error = msg;
        }
    }
%>

    <%@ include file="header.jsp" %>

    <main>
        <div class="page-header">
            <h2>Pond Management</h2>
            <button class="btn btn-secondary" onclick="openModal('addLocationModal')">+ New Location</button>
        </div>

        <% if (error != null) { %>
            <!-- future: show more detailed error  -->
            <div class="alert alert-danger"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <!--  -->
            <div class="alert alert-success"><%= success %></div>
        <% } %>

        <%-- Load locations once for the modal dropdowns and the listing --%>
        <%
            List<Integer> locationIds = new ArrayList<>();
            List<String> locationNames = new ArrayList<>();
            List<String> locationPrefixes = new ArrayList<>();
            try {
                if (con != null && !con.isClosed()) {
                    PreparedStatement locStmt = con.prepareStatement(
                        "SELECT id, name, prefix FROM pond_locations WHERE organization_id = ? ORDER BY display_order, name");
                    locStmt.setInt(1, (Integer) session.getAttribute("orgId"));
                    ResultSet locRs = locStmt.executeQuery();
                    while (locRs.next()) {
                        locationIds.add(locRs.getInt("id"));
                        locationNames.add(locRs.getString("name"));
                        String pfx = locRs.getString("prefix");
                        locationPrefixes.add(pfx != null ? pfx : "");
                    }
                    locRs.close();
                    locStmt.close();
                }
            } catch (Exception e) {
                error = "Error loading locations: " + e.getMessage();
            }

            boolean hasLocations = !locationIds.isEmpty();
        %>

        <% if (!hasLocations) { %>
            <div class="section empty-state">
                <p>No locations yet. Ponds are grouped by location (e.g. <em>Big Ponds</em>, <em>Backyard</em>, <em>Quarantine</em>).</p>
                <p><strong>Create your first location to get started.</strong></p>
                <button class="btn btn-primary" onclick="openModal('addLocationModal')">+ New Location</button>
            </div>
        <% } else { %>

        <%-- Add Pond button only shown when at least one location exists --%>
        <div style="margin-bottom: 1rem; text-align: right;">
            <button class="btn btn-primary" onclick="openModal('addModal')">+ Add Pond</button>
        </div>

        <%-- Load and display all ponds --%>
        <%
            // check if there are ponds and don't show otherwise
            boolean hasPonds = false;
            ResultSet rs = null;
            Statement stmt = null;

            try {
                if (con != null && !con.isClosed()) {
                    PreparedStatement pStmt = con.prepareStatement(
                        "SELECT p.*, l.name AS location_name, l.display_order AS location_order "
                      + "FROM ponds p LEFT JOIN pond_locations l ON p.location_id = l.id "
                      + "WHERE p.organization_id = ? ORDER BY l.display_order, p.code");
                    pStmt.setInt(1, (Integer) session.getAttribute("orgId"));
                    rs = pStmt.executeQuery();

                    if (rs.isBeforeFirst()) {
                        hasPonds = true;
                        int currentLocationId = -1;
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String code = rs.getString("code");
                            String name = rs.getString("name");
                            int locationId = rs.getInt("location_id");
                            String locationName = rs.getString("location_name");
                            double volume = rs.getDouble("volume");
                            boolean volumeNull = rs.wasNull();
                            String volumeUnit = rs.getString("volume_unit");
                            double length = rs.getDouble("length");
                            double width = rs.getDouble("width");
                            double depth = rs.getDouble("depth");
                            String filtrationType = rs.getString("filtration_type");
                            int uvBulbCount = rs.getInt("uv_bulb_count");
                            double uvBulbWattage = rs.getDouble("uv_bulb_wattage");
                            boolean isQuarantine = rs.getBoolean("is_quarantine");
                            String safeName = name != null ? name.replace("'", "\\'") : "";
                            String safeFiltration = filtrationType != null ? filtrationType.replace("'", "\\'") : "";
                            String volumeStr = volumeNull ? "" : String.valueOf(volume);
                            String volumeDisplay = volumeNull ? "—" : String.format("%,.0f", volume) + " " + volumeUnit;

                            if (locationId != currentLocationId) {
                                if (currentLocationId != -1) {
        %>
                </div>
            </section>
        <%
                                }
                                currentLocationId = locationId;
        %>
            <section class="pond-section">
                <h3 class="pond-section-heading"><%= locationName %></h3>
                <div class="pond-grid">
        <%
                            }
        %>
            <div class="card pond-card">
                <div class="pond-card-header">
                    <h3><%= code %><% if (isQuarantine) { %> <span class="badge badge-quarantine">Quarantine</span><% } %></h3>
                    <% if (name != null && !name.isEmpty() && !name.equals(code)) { %>
                        <p class="pond-card-subtitle"><%= name %></p>
                    <% } %>
                    <div class="pond-actions">
                        <button class="btn btn-sm btn-edit" onclick="openEditModal('<%= id %>','<%= code %>','<%= safeName %>','<%= locationId %>','<%= volumeStr %>','<%= volumeUnit %>','<%= length %>','<%= width %>','<%= depth %>','<%= safeFiltration %>','<%= uvBulbCount %>','<%= uvBulbWattage %>')">Edit</button>
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
                        <span class="detail-label">Volume</span>
                        <span class="detail-value"><%= volumeDisplay %></span>
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
                        if (currentLocationId != -1) {
        %>
                </div>
            </section>
        <%
                        }
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
        %>

        <% } /* end if (hasLocations) */ %>

        <%
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
                        <label for="add-code">Pond Code *</label>
                        <input type="text" id="add-code" name="code" placeholder="e.g. C2, S3A, JP" style="text-transform: uppercase;" required>
                    </div>
                    <div class="form-group">
                        <label for="add-name">Pond Name</label>
                        <input type="text" id="add-name" name="name" placeholder="Optional friendly name">
                    </div>
                    <div class="form-group">
                        <label for="add-locationId">Location *</label>
                        <select id="add-locationId" name="locationId" required onchange="applyLocationPrefix()">
                            <% for (int i = 0; i < locationIds.size(); i++) { %>
                                <option value="<%= locationIds.get(i) %>" data-prefix="<%= locationPrefixes.get(i) %>"><%= locationNames.get(i) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="add-volume">Volume</label>
                        <input type="number" id="add-volume" name="volume" step="0.1">
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
                        <label for="edit-code">Pond Code *</label>
                        <input type="text" id="edit-code" name="code" style="text-transform: uppercase;" required>
                    </div>
                    <div class="form-group">
                        <label for="edit-name">Pond Name</label>
                        <input type="text" id="edit-name" name="name" placeholder="Optional friendly name">
                    </div>
                    <div class="form-group">
                        <label for="edit-locationId">Location *</label>
                        <select id="edit-locationId" name="locationId" required>
                            <% for (int i = 0; i < locationIds.size(); i++) { %>
                                <option value="<%= locationIds.get(i) %>"><%= locationNames.get(i) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="edit-volume">Volume</label>
                        <input type="number" id="edit-volume" name="volume" step="0.1">
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

    <%-- Add Location Modal --%>
    <div id="addLocationModal" class="modal-overlay" onclick="if(event.target===this)closeModal('addLocationModal')">
        <div class="modal">
            <div class="modal-header">
                <h3>New Location</h3>
                <button class="modal-close" onclick="closeModal('addLocationModal')">&times;</button>
            </div>
            <form method="post" action="ponds.jsp">
                <input type="hidden" name="action" value="createLocation">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="add-locName">Location Name *</label>
                        <input type="text" id="add-locName" name="locName" placeholder="e.g. Big Ponds, Backyard" required>
                    </div>
                    <div class="form-group">
                        <label for="add-locPrefix">Pond Code Prefix</label>
                        <input type="text" id="add-locPrefix" name="locPrefix" maxlength="10" placeholder="e.g. C, JP" style="text-transform: uppercase;">
                    </div>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addLocationModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Create Location</button>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="footer.jsp" %>

    <script>
        function openModal(id) {
            document.getElementById(id).classList.add('active');
            if (id === 'addModal') applyLocationPrefix();
        }

        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }

        function applyLocationPrefix() {
            var sel = document.getElementById('add-locationId');
            if (!sel || !sel.options.length) return;
            var prefix = sel.options[sel.selectedIndex].dataset.prefix || '';
            document.getElementById('add-code').value = prefix;
        }

        function openEditModal(id, code, name, locationId, volume, volumeUnit, length, width, depth, filtrationType, uvBulbCount, uvBulbWattage) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-code').value = code;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-locationId').value = locationId;
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
