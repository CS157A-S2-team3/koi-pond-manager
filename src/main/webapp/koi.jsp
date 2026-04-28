<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.koi.MysqlCon" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    // Database connection
    java.sql.Connection con = null;
    String error = null;
    String success = null;
    int orgId = (Integer) session.getAttribute("orgId");
    int userId = (Integer) session.getAttribute("userId");

    try {
        con = MysqlCon.getConnection();

        // Handle form submissions
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String pondIdStr = request.getParameter("pondId");
            Integer pondId = (pondIdStr != null && !pondIdStr.isEmpty()) ? Integer.parseInt(pondIdStr) : null;

            // If pond specified, verify it belongs to this org
            if (pondId != null) {
                PreparedStatement verifyPs = con.prepareStatement("SELECT id FROM ponds WHERE id = ? AND organization_id = ?");
                verifyPs.setInt(1, pondId);
                verifyPs.setInt(2, orgId);
                ResultSet verifyRs = verifyPs.executeQuery();
                if (!verifyRs.next()) {
                    verifyRs.close();
                    verifyPs.close();
                    error = "Invalid pond selection.";
                    pondId = null;
                } else {
                    verifyRs.close();
                    verifyPs.close();
                }
            }

            if (error == null) {
                String sql = "INSERT INTO koi (organization_id, name, age, variety, breeder, sex, size_cm, status, pond_id, notes) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                ps.setInt(1, orgId);
                ps.setString(2, request.getParameter("name"));
                String ageStr = request.getParameter("age");
                if (ageStr != null && !ageStr.isEmpty()) ps.setInt(3, Integer.parseInt(ageStr));
                else ps.setNull(3, Types.INTEGER);
                ps.setString(4, request.getParameter("variety"));
                ps.setString(5, request.getParameter("breeder"));
                ps.setString(6, request.getParameter("sex"));
                String sizeStr = request.getParameter("sizeCm");
                if (sizeStr != null && !sizeStr.isEmpty()) ps.setDouble(7, Double.parseDouble(sizeStr));
                else ps.setNull(7, Types.DOUBLE);
                ps.setString(8, request.getParameter("status"));
                if (pondId != null) ps.setInt(9, pondId);
                else ps.setNull(9, Types.INTEGER);
                ps.setString(10, request.getParameter("notes"));
                ps.executeUpdate();

                // Get the new koi id for history
                ResultSet keys = ps.getGeneratedKeys();
                int newKoiId = 0;
                if (keys.next()) newKoiId = keys.getInt(1);
                keys.close();
                ps.close();

                // Record pond assignment history if assigned to a pond
                if (pondId != null && newKoiId > 0) {
                    PreparedStatement histPs = con.prepareStatement(
                        "INSERT INTO koi_pond_history (koi_id, from_pond_id, to_pond_id, moved_by) VALUES (?, NULL, ?, ?)");
                    histPs.setInt(1, newKoiId);
                    histPs.setInt(2, pondId);
                    histPs.setInt(3, userId);
                    histPs.executeUpdate();
                    histPs.close();
                }

                success = "Koi created successfully.";
            }

        } else if ("update".equals(action)) {
            int koiId = Integer.parseInt(request.getParameter("id"));
            String pondIdStr = request.getParameter("pondId");
            Integer newPondId = (pondIdStr != null && !pondIdStr.isEmpty()) ? Integer.parseInt(pondIdStr) : null;

            // Verify koi belongs to this organization and get current pond_id
            PreparedStatement lookupPs = con.prepareStatement("SELECT pond_id FROM koi WHERE id = ? AND organization_id = ?");
            lookupPs.setInt(1, koiId);
            lookupPs.setInt(2, orgId);
            ResultSet lookupRs = lookupPs.executeQuery();

            if (!lookupRs.next()) {
                error = "Koi not found.";
            } else {
                Integer oldPondId = lookupRs.getObject("pond_id") != null ? lookupRs.getInt("pond_id") : null;
                lookupRs.close();
                lookupPs.close();

                // If new pond specified, verify it belongs to this organization
                if (newPondId != null) {
                    PreparedStatement verifyPs = con.prepareStatement("SELECT id FROM ponds WHERE id = ? AND organization_id = ?");
                    verifyPs.setInt(1, newPondId);
                    verifyPs.setInt(2, orgId);
                    ResultSet verifyRs = verifyPs.executeQuery();
                    if (!verifyRs.next()) {
                        error = "Invalid pond selection.";
                    }
                    verifyRs.close();
                    verifyPs.close();
                }

                if (error == null) {
                    String sql = "UPDATE koi SET name=?, age=?, variety=?, breeder=?, sex=?, size_cm=?, status=?, pond_id=?, notes=? "
                               + "WHERE id=? AND organization_id=?";
                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, request.getParameter("name"));
                    String ageStr = request.getParameter("age");
                    if (ageStr != null && !ageStr.isEmpty()) ps.setInt(2, Integer.parseInt(ageStr));
                    else ps.setNull(2, Types.INTEGER);
                    ps.setString(3, request.getParameter("variety"));
                    ps.setString(4, request.getParameter("breeder"));
                    ps.setString(5, request.getParameter("sex"));
                    String sizeStr = request.getParameter("sizeCm");
                    if (sizeStr != null && !sizeStr.isEmpty()) ps.setDouble(6, Double.parseDouble(sizeStr));
                    else ps.setNull(6, Types.DOUBLE);
                    ps.setString(7, request.getParameter("status"));
                    if (newPondId != null) ps.setInt(8, newPondId);
                    else ps.setNull(8, Types.INTEGER);
                    ps.setString(9, request.getParameter("notes"));
                    ps.setInt(10, koiId);
                    ps.setInt(11, orgId);
                    ps.executeUpdate();
                    ps.close();

                    // Record pond assignment history if pond changed
                    boolean pondChanged = (oldPondId == null && newPondId != null)
                        || (oldPondId != null && !oldPondId.equals(newPondId));
                    if (pondChanged) {
                        PreparedStatement histPs = con.prepareStatement(
                            "INSERT INTO koi_pond_history (koi_id, from_pond_id, to_pond_id, moved_by) VALUES (?, ?, ?, ?)");
                        histPs.setInt(1, koiId);
                        if (oldPondId != null) histPs.setInt(2, oldPondId);
                        else histPs.setNull(2, Types.INTEGER);
                        if (newPondId != null) histPs.setInt(3, newPondId);
                        else histPs.setNull(3, Types.INTEGER);
                        histPs.setInt(4, userId);
                        histPs.executeUpdate();
                        histPs.close();
                    }

                    success = "Koi updated successfully.";
                }
            }

        } else if ("delete".equals(action)) {
            int koiId = Integer.parseInt(request.getParameter("id"));
            // Delete history first (FK constraint)
            PreparedStatement histPs = con.prepareStatement("DELETE FROM koi_pond_history WHERE koi_id = ?");
            histPs.setInt(1, koiId);
            histPs.executeUpdate();
            histPs.close();
            // Delete koi with org check
            PreparedStatement ps = con.prepareStatement("DELETE FROM koi WHERE id = ? AND organization_id = ?");
            ps.setInt(1, koiId);
            ps.setInt(2, orgId);
            ps.executeUpdate();
            ps.close();
            success = "Koi deleted.";
        }

    } catch (Exception e) {
        error = e.getMessage();
    }

    // Load ponds for dropdowns
    List<int[]> pondIds = new ArrayList<>();
    List<String> pondNames = new ArrayList<>();
    try {
        if (con != null && !con.isClosed()) {
            PreparedStatement pondPs = con.prepareStatement("SELECT id, name FROM ponds WHERE organization_id = ? ORDER BY name");
            pondPs.setInt(1, orgId);
            ResultSet pondRs = pondPs.executeQuery();
            while (pondRs.next()) {
                pondIds.add(new int[]{pondRs.getInt("id")});
                pondNames.add(pondRs.getString("name"));
            }
            pondRs.close();
            pondPs.close();
        }
    } catch (Exception e) { /* ignore */ }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Koi - Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
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
        <div class="user-menu">
            <span class="user-name"><%= session.getAttribute("fullName") %></span>
            <span class="user-role"><%= session.getAttribute("role") %></span>
            <a href="logout" class="btn-logout">Sign Out</a>
        </div>
    </header>

    <main>
        <div class="page-header">
            <h2>Koi Inventory</h2>
            <button class="btn btn-primary" onclick="openModal('addModal')">+ Add Koi</button>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <div class="alert alert-success"><%= success %></div>
        <% } %>

        <%-- Load and display all koi --%>
        <%
            boolean hasKoi = false;
            ResultSet rs = null;

            try {
                if (con != null && !con.isClosed()) {
                    PreparedStatement pStmt = con.prepareStatement(
                        "SELECT k.*, p.name AS pond_name FROM koi k "
                        + "LEFT JOIN ponds p ON k.pond_id = p.id "
                        + "WHERE k.organization_id = ? ORDER BY k.name");
                    pStmt.setInt(1, orgId);
                    rs = pStmt.executeQuery();

                    if (rs.isBeforeFirst()) {
                        hasKoi = true;
        %>
        <div class="pond-grid">
            <%
                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String name = rs.getString("name");
                            int age = rs.getInt("age");
                            boolean ageNull = rs.wasNull();
                            String variety = rs.getString("variety");
                            String breeder = rs.getString("breeder");
                            String sex = rs.getString("sex");
                            double sizeCm = rs.getDouble("size_cm");
                            boolean sizeNull = rs.wasNull();
                            String status = rs.getString("status");
                            int pondId = rs.getInt("pond_id");
                            boolean pondNull = rs.wasNull();
                            String pondName = rs.getString("pond_name");
                            String notes = rs.getString("notes");

                            String badgeClass;
                            switch (status) {
                                case "healthy": badgeClass = "badge-good"; break;
                                case "injured": case "sick": badgeClass = "badge-warn"; break;
                                case "deceased": badgeClass = "badge-danger"; break;
                                default: badgeClass = "";
                            }

                            // Escape strings for JS
                            String jsName = name != null ? name.replace("'", "\\'").replace("\"", "&quot;") : "";
                            String jsVariety = variety != null ? variety.replace("'", "\\'") : "";
                            String jsBreeder = breeder != null ? breeder.replace("'", "\\'") : "";
                            String jsNotes = notes != null ? notes.replace("'", "\\'").replace("\n", "\\n") : "";
            %>
            <div class="card pond-card">
                <div class="pond-card-header">
                    <h3><%= name %></h3>
                    <div class="pond-actions">
                        <span class="badge <%= badgeClass %>"><%= status %></span>
                        <button class="btn btn-sm btn-edit" onclick="openEditModal(<%= id %>,
                            '<%= jsName %>',
                            '<%= ageNull ? "" : age %>',
                            '<%= jsVariety %>',
                            '<%= jsBreeder %>',
                            '<%= sex %>',
                            '<%= sizeNull ? "" : sizeCm %>',
                            '<%= status %>',
                            '<%= pondNull ? "" : pondId %>',
                            '<%= jsNotes %>')">Edit</button>
                        <form method="post" action="koi.jsp" style="display:inline;"
                              onsubmit="return confirm('Delete this koi?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="id" value="<%= id %>">
                            <button type="submit" class="btn btn-sm btn-danger-outline">Delete</button>
                        </form>
                    </div>
                </div>
                <div class="pond-details">
                    <div class="detail-row">
                        <span class="detail-label">Variety</span>
                        <span class="detail-value"><%= variety != null ? variety : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Sex</span>
                        <span class="detail-value"><%= sex != null ? sex.substring(0,1).toUpperCase() + sex.substring(1) : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Age</span>
                        <span class="detail-value"><%= !ageNull ? age + " yr" + (age != 1 ? "s" : "") : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Size</span>
                        <span class="detail-value"><%= !sizeNull ? sizeCm + " cm" : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Breeder</span>
                        <span class="detail-value"><%= breeder != null ? breeder : "—" %></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Pond</span>
                        <span class="detail-value"><%= pondName != null ? pondName : "Unassigned" %></span>
                    </div>
                    <% if (notes != null && !notes.isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Notes</span>
                        <span class="detail-value"><%= notes %></span>
                    </div>
                    <% } %>
                </div>
            </div>
            <%
                        }
            %>
        </div>
        <%
                    }
                    if (rs != null) rs.close();
                }
            } catch (Exception e) {
        %>
            <div class="alert alert-danger">Error loading koi: <%= e.getMessage() %></div>
        <%
            }

            if (!hasKoi) {
        %>
        <div class="section empty-state">
            <p>No koi yet. Click <strong>+ Add Koi</strong> to add your first fish.</p>
        </div>
        <%
            }

            // Close connection
            if (con != null) {
                try { con.close(); } catch (SQLException e) { /* ignore */ }
            }
        %>
    </main>

    <%-- Add Koi Modal --%>
    <div id="addModal" class="modal-overlay" onclick="if(event.target===this)closeModal('addModal')">
        <div class="modal">
            <div class="modal-header">
                <h3>Add New Koi</h3>
                <button class="modal-close" onclick="closeModal('addModal')">&times;</button>
            </div>
            <form method="post" action="koi.jsp">
                <input type="hidden" name="action" value="create">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="add-name">Name *</label>
                        <input type="text" id="add-name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="add-variety">Variety</label>
                        <input type="text" id="add-variety" name="variety" placeholder="e.g. Kohaku, Showa">
                    </div>
                    <div class="form-group">
                        <label for="add-sex">Sex</label>
                        <select id="add-sex" name="sex">
                            <option value="unknown">Unknown</option>
                            <option value="male">Male</option>
                            <option value="female">Female</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="add-age">Age (years)</label>
                        <input type="number" id="add-age" name="age" min="0">
                    </div>
                    <div class="form-group">
                        <label for="add-sizeCm">Size (cm)</label>
                        <input type="number" id="add-sizeCm" name="sizeCm" step="0.1" min="0">
                    </div>
                    <div class="form-group">
                        <label for="add-breeder">Breeder</label>
                        <input type="text" id="add-breeder" name="breeder" placeholder="e.g. Dainichi, Sakai">
                    </div>
                    <div class="form-group">
                        <label for="add-status">Status</label>
                        <select id="add-status" name="status">
                            <option value="healthy">Healthy</option>
                            <option value="injured">Injured</option>
                            <option value="sick">Sick</option>
                            <option value="deceased">Deceased</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="add-pondId">Pond</label>
                        <select id="add-pondId" name="pondId">
                            <option value="">Unassigned</option>
                            <% for (int i = 0; i < pondIds.size(); i++) { %>
                                <option value="<%= pondIds.get(i)[0] %>"><%= pondNames.get(i) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group" style="grid-column: 1 / -1;">
                        <label for="add-notes">Notes</label>
                        <textarea id="add-notes" name="notes" rows="3" style="padding:0.5rem 0.75rem;border:1px solid var(--border);border-radius:6px;font-size:0.9rem;font-family:inherit;resize:vertical;"></textarea>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="closeModal('addModal')">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Koi</button>
                </div>
            </form>
        </div>
    </div>

    <%-- Edit Koi Modal --%>
    <div id="editModal" class="modal-overlay" onclick="if(event.target===this)closeModal('editModal')">
        <div class="modal">
            <div class="modal-header">
                <h3>Edit Koi</h3>
                <button class="modal-close" onclick="closeModal('editModal')">&times;</button>
            </div>
            <form method="post" action="koi.jsp">
                <input type="hidden" name="action" value="update">
                <input type="hidden" id="edit-id" name="id">
                <div class="form-grid">
                    <div class="form-group">
                        <label for="edit-name">Name *</label>
                        <input type="text" id="edit-name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="edit-variety">Variety</label>
                        <input type="text" id="edit-variety" name="variety">
                    </div>
                    <div class="form-group">
                        <label for="edit-sex">Sex</label>
                        <select id="edit-sex" name="sex">
                            <option value="unknown">Unknown</option>
                            <option value="male">Male</option>
                            <option value="female">Female</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="edit-age">Age (years)</label>
                        <input type="number" id="edit-age" name="age" min="0">
                    </div>
                    <div class="form-group">
                        <label for="edit-sizeCm">Size (cm)</label>
                        <input type="number" id="edit-sizeCm" name="sizeCm" step="0.1" min="0">
                    </div>
                    <div class="form-group">
                        <label for="edit-breeder">Breeder</label>
                        <input type="text" id="edit-breeder" name="breeder">
                    </div>
                    <div class="form-group">
                        <label for="edit-status">Status</label>
                        <select id="edit-status" name="status">
                            <option value="healthy">Healthy</option>
                            <option value="injured">Injured</option>
                            <option value="sick">Sick</option>
                            <option value="deceased">Deceased</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="edit-pondId">Pond</label>
                        <select id="edit-pondId" name="pondId">
                            <option value="">Unassigned</option>
                            <% for (int i = 0; i < pondIds.size(); i++) { %>
                                <option value="<%= pondIds.get(i)[0] %>"><%= pondNames.get(i) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group" style="grid-column: 1 / -1;">
                        <label for="edit-notes">Notes</label>
                        <textarea id="edit-notes" name="notes" rows="3" style="padding:0.5rem 0.75rem;border:1px solid var(--border);border-radius:6px;font-size:0.9rem;font-family:inherit;resize:vertical;"></textarea>
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

        function openEditModal(id, name, age, variety, breeder, sex, sizeCm, status, pondId, notes) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-age').value = age;
            document.getElementById('edit-variety').value = variety;
            document.getElementById('edit-breeder').value = breeder;
            document.getElementById('edit-sex').value = sex;
            document.getElementById('edit-sizeCm').value = sizeCm;
            document.getElementById('edit-status').value = status;
            document.getElementById('edit-pondId').value = pondId;
            document.getElementById('edit-notes').value = notes;
            openModal('editModal');
        }
    </script>

</body>
</html>
