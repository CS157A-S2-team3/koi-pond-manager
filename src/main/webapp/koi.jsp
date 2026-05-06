<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat, com.koi.MysqlCon, com.koi.EnvLoader" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    java.sql.Connection con = null;
    String error = null;
    String success = null;
    int orgId = (Integer) session.getAttribute("orgId");
    int userId = (Integer) session.getAttribute("userId");

    try {
        con = MysqlCon.getConnection();

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String pondIdStr = request.getParameter("pondId");
            Integer pondId = (pondIdStr != null && !pondIdStr.isEmpty()) ? Integer.parseInt(pondIdStr) : null;

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
                String sql = "INSERT INTO koi (organization_id, name, age, variety, breeder, sex, size_cm, status, pond_id, notes, image_url) "
                           + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
                String imgParam = request.getParameter("imageUrl");
                if (imgParam != null && !imgParam.isEmpty()) ps.setString(11, imgParam.trim());
                else ps.setNull(11, Types.VARCHAR);
                ps.executeUpdate();

                ResultSet keys = ps.getGeneratedKeys();
                int newKoiId = 0;
                if (keys.next()) newKoiId = keys.getInt(1);
                keys.close();
                ps.close();

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

                boolean transferAttempted = (oldPondId == null && newPondId != null)
                    || (oldPondId != null && !oldPondId.equals(newPondId));

                if (error == null && transferAttempted) {
                    PreparedStatement quarantinePs = con.prepareStatement(
                        "SELECT code FROM ponds WHERE id = ? AND is_quarantine = 1"
                    );

                    if (newPondId != null) {
                        quarantinePs.setInt(1, newPondId);
                        ResultSet quarantineRs = quarantinePs.executeQuery();

                        if (quarantineRs.next()) {
                            error = "Transfer blocked: " + quarantineRs.getString("code") + " is marked as quarantine.";
                        }

                        quarantineRs.close();
                    }

                    if (error == null && oldPondId != null) {
                        quarantinePs.setInt(1, oldPondId);
                        ResultSet quarantineRs = quarantinePs.executeQuery();

                        if (quarantineRs.next()) {
                            error = "Transfer blocked: " + quarantineRs.getString("code") + " is marked as quarantine.";
                        }

                        quarantineRs.close();
                    }

                    quarantinePs.close();
                }

                if (error == null) {
                    String sql = "UPDATE koi SET name=?, age=?, variety=?, breeder=?, sex=?, size_cm=?, status=?, pond_id=?, notes=?, image_url=? "
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
                    String imgParam = request.getParameter("imageUrl");
                    if (imgParam != null && !imgParam.isEmpty()) ps.setString(10, imgParam.trim());
                    else ps.setNull(10, Types.VARCHAR);
                    ps.setInt(11, koiId);
                    ps.setInt(12, orgId);
                    ps.executeUpdate();
                    ps.close();

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

            PreparedStatement histPs = con.prepareStatement("DELETE FROM koi_pond_history WHERE koi_id = ?");
            histPs.setInt(1, koiId);
            histPs.executeUpdate();
            histPs.close();

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

    List<int[]> pondIds = new ArrayList<>();
    List<String> pondNames = new ArrayList<>();
    try {
        if (con != null && !con.isClosed()) {
            PreparedStatement pondPs = con.prepareStatement("SELECT id, code FROM ponds WHERE organization_id = ? ORDER BY code");
            pondPs.setInt(1, orgId);
            ResultSet pondRs = pondPs.executeQuery();
            while (pondRs.next()) {
                pondIds.add(new int[]{pondRs.getInt("id")});
                pondNames.add(pondRs.getString("code"));
            }
            pondRs.close();
            pondPs.close();
        }
    } catch (Exception e) { }

    String selectedIdParam = request.getParameter("selectedId");
    int profileId = -1;
    boolean showProfile = false;
    String profName = "", profVariety = "—", profBreeder = "—", profSex = "—";
    String profAge = "—", profSize = "—", profPond = "—", profStatus = "—";
    String profNotes = "", profDeceased = "", profImageUrl = "";
    StringBuilder profHistRows = new StringBuilder();
    boolean profHasHistory = false;

    if (selectedIdParam != null) {
        try { profileId = Integer.parseInt(selectedIdParam); } catch (NumberFormatException e) {}
    }

    if (profileId > 0) {
        try {
            if (con == null || con.isClosed()) con = MysqlCon.getConnection();
            PreparedStatement profPs = con.prepareStatement(
                "SELECT k.*, p.name AS pond_name FROM koi k "
              + "LEFT JOIN ponds p ON k.pond_id = p.id "
              + "WHERE k.id = ? AND k.organization_id = ?");
            profPs.setInt(1, profileId);
            profPs.setInt(2, orgId);
            ResultSet profRs = profPs.executeQuery();
            if (profRs.next()) {
                showProfile = true;
                profName    = profRs.getString("name") != null ? profRs.getString("name") : "";
                String v = profRs.getString("variety");  if (v != null && !v.isEmpty()) profVariety = v;
                String b = profRs.getString("breeder");  if (b != null && !b.isEmpty()) profBreeder = b;
                String s = profRs.getString("sex");      if (s != null && !s.isEmpty()) profSex = s;
                int pAge = profRs.getInt("age");
                if (!profRs.wasNull()) profAge = pAge + " yr" + (pAge != 1 ? "s" : "");
                double pSize = profRs.getDouble("size_cm");
                if (!profRs.wasNull()) profSize = String.format("%.2f cm", pSize);
                String pn = profRs.getString("pond_name");
                profPond = pn != null ? pn : "Unassigned";
                String st = profRs.getString("status");  if (st != null) profStatus = st;
                String n = profRs.getString("notes");    if (n != null) profNotes = n;
                String iu = profRs.getString("image_url"); if (iu != null) profImageUrl = iu;
                java.sql.Timestamp upd = profRs.getTimestamp("updated_at");
                if ("deceased".equals(profStatus) && upd != null) {
                    profDeceased = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a").format(upd);
                }
            }
            profRs.close();
            profPs.close();

            if (showProfile) {
                PreparedStatement histPs = con.prepareStatement(
                    "SELECT kph.moved_at, "
                  + "(SELECT code FROM ponds WHERE id = kph.from_pond_id) AS from_name, "
                  + "(SELECT code FROM ponds WHERE id = kph.to_pond_id) AS to_name "
                  + "FROM koi_pond_history kph "
                  + "WHERE kph.koi_id = ? ORDER BY kph.moved_at ASC");
                histPs.setInt(1, profileId);
                ResultSet histRs = histPs.executeQuery();
                SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                while (histRs.next()) {
                    profHasHistory = true;
                    String fromN = histRs.getString("from_name");
                    String toN = histRs.getString("to_name");
                    profHistRows.append("<tr><td>").append(sdf.format(histRs.getTimestamp("moved_at"))).append("</td>")
                                .append("<td>").append(fromN != null ? fromN : "None").append("</td>")
                                .append("<td>").append(toN != null ? toN : "None").append("</td></tr>");
                }
                histRs.close();
                histPs.close();
            }
        } catch (Exception e) { }
    }
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

    <%@ include file="header.jsp" %>

    <main>
        <%
            String shopifyDomain = null;
            try { shopifyDomain = EnvLoader.get("SHOPIFY_SHOP_DOMAIN"); } catch (Exception ignore) {}
            boolean showShopifyImport = "admin".equals(session.getAttribute("role"))
                                     && shopifyDomain != null && !shopifyDomain.isEmpty();
        %>
        <div class="page-header">
            <h2>Koi Inventory</h2>
            <div>
                <% if (showShopifyImport) { %>
                    <a href="import-koi.jsp" class="btn btn-secondary">Import from Shopify</a>
                <% } %>
                <button class="btn btn-primary" onclick="openModal('addModal')">+ Add Koi</button>
            </div>
        </div>

        <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>

        <% if (success != null) { %>
            <div class="alert alert-success"><%= success %></div>
        <% } %>

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
        <div class="koi-grid">
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
                            String imageUrl = rs.getString("image_url");

                            String badgeClass;
                            switch (status) {
                                case "healthy": badgeClass = "badge-good"; break;
                                case "injured": case "sick": badgeClass = "badge-warn"; break;
                                case "deceased": badgeClass = "badge-danger"; break;
                                default: badgeClass = "";
                            }

                            String jsName = name != null ? name.replace("'", "\\'").replace("\"", "&quot;") : "";
                            String jsVariety = variety != null ? variety.replace("'", "\\'") : "";
                            String jsBreeder = breeder != null ? breeder.replace("'", "\\'") : "";
                            String jsNotes = notes != null ? notes.replace("'", "\\'").replace("\n", "\\n") : "";
                            String jsImageUrl = imageUrl != null ? imageUrl.replace("'", "\\'") : "";
                            String jsAge = ageNull ? "" : String.valueOf(age);
                            String jsSize = sizeNull ? "" : String.valueOf(sizeCm);
                            String jsPondId = pondNull ? "" : String.valueOf(pondId);

                            // Build "size · age · sex" overlay (only the parts we have)
                            List<String> bits = new ArrayList<>();
                            if (!sizeNull) bits.add(((long) sizeCm) + " cm");
                            if (!ageNull)  bits.add(age + " yr" + (age != 1 ? "s" : ""));
                            if (sex != null && !"unknown".equals(sex)) {
                                bits.add(sex.substring(0, 1).toUpperCase() + sex.substring(1));
                            }
                            String specsOverlay = String.join(" · ", bits);

                            // Subtitle below name: variety · pond
                            List<String> metaBits = new ArrayList<>();
                            if (variety != null && !variety.isEmpty()) metaBits.add(variety);
                            metaBits.add(pondName != null ? pondName : "Unassigned");
                            String metaLine = String.join(" · ", metaBits);
            %>
            <div class="koi-card">
                <a class="koi-card-link" href="koi.jsp?selectedId=<%= id %>">
                    <div class="koi-card-media">
                        <% if (imageUrl != null && !imageUrl.isEmpty()) { %>
                            <img class="koi-card-img" src="<%= imageUrl %>" alt="<%= name %>" loading="lazy">
                        <% } else { %>
                            <div class="koi-card-empty">No photo</div>
                        <% } %>
                        <% if (breeder != null && !breeder.isEmpty()) { %>
                            <div class="koi-card-overlay koi-card-overlay-tl"><%= breeder %></div>
                        <% } %>
                        <% if (!specsOverlay.isEmpty()) { %>
                            <div class="koi-card-overlay koi-card-overlay-bl"><%= specsOverlay %></div>
                        <% } %>
                        <% if (!"healthy".equals(status)) { %>
                            <span class="koi-card-status badge <%= badgeClass %>"><%= status %></span>
                        <% } %>
                    </div>
                    <div class="koi-card-body">
                        <h3 class="koi-card-title"><%= name %></h3>
                        <p class="koi-card-meta"><%= metaLine %></p>
                    </div>
                </a>
                <div class="koi-card-actions">
                    <button class="btn btn-sm btn-edit" onclick="openEditModal('<%= id %>','<%= jsName %>','<%= jsAge %>','<%= jsVariety %>','<%= jsBreeder %>','<%= sex %>','<%= jsSize %>','<%= status %>','<%= jsPondId %>','<%= jsNotes %>','<%= jsImageUrl %>')">Edit</button>
                    <form method="post" action="koi.jsp" style="display:inline;"
                          onsubmit="return confirm('Delete this koi?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= id %>">
                        <button type="submit" class="btn btn-sm btn-danger-outline">Delete</button>
                    </form>
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

            if (con != null) {
                try { con.close(); } catch (SQLException e) { }
            }
        %>
    </main>

    <div id="profileModal" class="modal-overlay <%= showProfile ? "active" : "" %>" onclick="if(event.target===this)window.location='koi.jsp'">
        <div class="modal">
            <div class="modal-header">
                <h3><%= profName %></h3>
                <a href="koi.jsp" class="modal-close" style="text-decoration:none;">&times;</a>
            </div>
            <% if (!profImageUrl.isEmpty()) { %>
                <img class="koi-photo" src="<%= profImageUrl %>" alt="<%= profName %>">
            <% } %>
            <div class="pond-details" style="padding:1.5rem;">
                <div class="detail-row"><span class="detail-label">Variety</span><span class="detail-value"><%= profVariety %></span></div>
                <div class="detail-row"><span class="detail-label">Breeder</span><span class="detail-value"><%= profBreeder %></span></div>
                <div class="detail-row"><span class="detail-label">Sex</span><span class="detail-value"><%= profSex %></span></div>
                <div class="detail-row"><span class="detail-label">Age</span><span class="detail-value"><%= profAge %></span></div>
                <div class="detail-row"><span class="detail-label">Size</span><span class="detail-value"><%= profSize %></span></div>
                <div class="detail-row"><span class="detail-label">Pond</span><span class="detail-value"><%= profPond %></span></div>
                <div class="detail-row"><span class="detail-label">Status</span><span class="detail-value"><%= profStatus %></span></div>
                <% if (!profDeceased.isEmpty()) { %>
                <div class="detail-row"><span class="detail-label">Date of Death</span><span class="detail-value"><%= profDeceased %></span></div>
                <% } %>
                <% if (!profNotes.isEmpty()) { %>
                <div class="detail-row"><span class="detail-label">Notes</span><span class="detail-value"><%= profNotes %></span></div>
                <% } %>
            </div>
            <div style="padding:0 1.5rem 1.5rem;">
                <h4 style="margin:0 0 0.5rem 0;font-size:0.95rem;">Pond Assignment History</h4>
                <% if (profHasHistory) { %>
                <table style="width:100%;border-collapse:collapse;font-size:0.9rem;">
                    <thead>
                        <tr style="text-align:left;border-bottom:1px solid var(--border);">
                            <th style="padding:0.4rem 0;">Date &amp; Time</th>
                            <th style="padding:0.4rem 0;">From Pond</th>
                            <th style="padding:0.4rem 0;">To Pond</th>
                        </tr>
                    </thead>
                    <tbody><%= profHistRows.toString() %></tbody>
                </table>
                <% } else { %>
                <p style="color:var(--text-light);margin:0;">No pond transfers recorded.</p>
                <% } %>
            </div>
        </div>
    </div>

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
                        <label for="add-imageUrl">Image URL</label>
                        <input type="url" id="add-imageUrl" name="imageUrl" placeholder="https://...">
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
                        <label for="edit-imageUrl">Image URL</label>
                        <input type="url" id="edit-imageUrl" name="imageUrl" placeholder="https://...">
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

        function openEditModal(id, name, age, variety, breeder, sex, sizeCm, status, pondId, notes, imageUrl) {
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
            document.getElementById('edit-imageUrl').value = imageUrl || '';
            openModal('editModal');
        }
    </script>

</body>
</html>