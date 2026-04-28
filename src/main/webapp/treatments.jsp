<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<%
    // Database connection
    java.sql.Connection treatCon = null;
    String error = request.getParameter("error");
    String success = null;

    try {
        treatCon = MysqlCon.getConnection();

        // Handle form submissions
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            int pondId = Integer.parseInt(request.getParameter("pondId"));
            int orgId = (Integer) session.getAttribute("orgId");

            // Verify the pond belongs to the user's organization
            PreparedStatement verifyPs = treatCon.prepareStatement("SELECT id FROM ponds WHERE id = ? AND organization_id = ?");
            verifyPs.setInt(1, pondId);
            verifyPs.setInt(2, orgId);
            ResultSet verifyRs = verifyPs.executeQuery();
            if (!verifyRs.next()) {
                verifyRs.close();
                verifyPs.close();
                error = "Invalid pond selection.";
            } else {
                verifyRs.close();
                verifyPs.close();

                int userId = (Integer) session.getAttribute("userId");
                String medication = request.getParameter("medication");
                String purpose = request.getParameter("purpose");
                double dosage = Double.parseDouble(request.getParameter("dosage"));
                String dosageUnit = request.getParameter("dosageUnit");
                int duration = Integer.parseInt(request.getParameter("duration"));
                double pondVolume = Double.parseDouble(request.getParameter("pondVolume"));
                String notes = request.getParameter("notes");
                boolean quarantine = request.getParameter("quarantine") != null;

                String sql = "INSERT INTO treatments "
                        + "(pond_id, user_id, medication, purpose, dosage, dosage_unit, duration, pond_volume, notes, quarantine) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = treatCon.prepareStatement(sql);
                ps.setInt(1, pondId);
                ps.setInt(2, userId);
                ps.setString(3, medication);
                ps.setString(4, purpose);
                ps.setDouble(5, dosage);
                ps.setString(6, dosageUnit);
                ps.setInt(7, duration);
                ps.setDouble(8, pondVolume);
                ps.setString(9, notes);
                ps.setBoolean(10, quarantine);
                ps.executeUpdate();
                ps.close();

                // Quarantine updates pond status
                if (quarantine) {
                    PreparedStatement pondPs = treatCon.prepareStatement("UPDATE ponds SET is_quarantine = ? WHERE id = ? AND organization_id = ?");
                    pondPs.setBoolean(1, true);
                    pondPs.setInt(2, pondId);
                    pondPs.setInt(3, orgId);
                    pondPs.executeUpdate();
                    pondPs.close();
                }

                success = "Treatment created successfully.";
            }
        }

    } catch (Exception e) {
        error = e.getMessage();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatment Management</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        body {
            background: #f5f7fb;
        }

        .page-wrap {
            max-width: 1240px;
            margin: 0 auto;
            padding: 2rem 1.5rem 3rem;
        }

        .page-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            flex-wrap: wrap;
        }

        .page-title {
            margin: 0;
            font-size: 2rem;
            color: #1f2937;
        }

        .page-subtitle {
            color: #6c757d;
            margin: 0 0 1.5rem 0;
            line-height: 1.6;
        }

        .top-action-btn {
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 999px;
            padding: 0.9rem 1.4rem;
            font: inherit;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(37, 99, 235, 0.18);
        }

        .top-action-btn:hover {
            background: #1d4ed8;
        }

        .alert-box {
            border-radius: 10px;
            padding: 0.95rem 1rem;
            margin-bottom: 1rem;
            font-weight: 600;
        }

        .alert-success {
            background: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }

        .alert-error {
            background: #f8d7da;
            color: #842029;
            border: 1px solid #f1aeb5;
        }

        .content-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
        }

        .content-card h3 {
            margin-bottom: 0.35rem;
            color: #1f2937;
        }

        .muted-text {
            color: #6c757d;
            line-height: 1.6;
        }

        .table-wrap {
            margin-top: 1rem;
            overflow-x: auto;
        }

        .treatment-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 900px;
        }

        .treatment-table th {
            text-align: left;
            background: #eff6ff;
            padding: 1rem;
            font-size: 0.95rem;
            color: #1f2937;
        }

        .treatment-table td {
            padding: 1rem;
            border-bottom: 1px solid #edf0f2;
            background: #fff;
            vertical-align: middle;
        }

        .status-tag {
            display: inline-block;
            padding: 0.3rem 0.7rem;
            border-radius: 999px;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
        }

        .status-active {
            background: #d1e7dd;
            color: #0f5132;
        }

        .status-quarantine {
            background: #f8d7da;
            color: #842029;
        }

        .table-btn {
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 8px;
            padding: 0.55rem 0.9rem;
            font: inherit;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }

        .table-btn:hover {
            background: #1d4ed8;
        }

        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        .info-panel {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 1.6rem;
            min-height: 220px;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
        }

        .info-icon {
            font-size: 2rem;
            margin-bottom: 0.9rem;
        }

        .info-panel h3 {
            margin-bottom: 0.7rem;
            font-size: 1.35rem;
            color: #1f2937;
        }

        .info-panel p {
            margin: 0;
            font-size: 1rem;
            color: #4b5563;
            line-height: 1.65;
        }

        .info-panel ul {
            margin-top: 0.8rem;
            padding-left: 1.1rem;
            color: #4b5563;
            line-height: 1.6;
        }

        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.45);
            justify-content: center;
            align-items: center;
            z-index: 1000;
            padding: 1.5rem;
        }

        .modal-box {
            background: white;
            width: 100%;
            max-width: 760px;
            border-radius: 16px;
            padding: 2rem;
            border: 1px solid #e5e7eb;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-header {
            margin-bottom: 1.5rem;
        }

        .modal-header h2 {
            margin: 0 0 0.6rem 0;
            color: #1d4ed8;
            font-size: 1.85rem;
        }

        .modal-sub {
            color: #6c757d;
            line-height: 1.6;
        }

        .modal-divider {
            border: none;
            border-top: 2px solid #e5eefb;
            margin: 1rem 0 0 0;
        }

        .form-section-title {
            font-size: 0.92rem;
            font-weight: 800;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin: 1.2rem 0 0.85rem;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem 1.25rem;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 700;
            margin-bottom: 0.45rem;
            font-size: 0.96rem;
            color: #374151;
        }

        .field-badge {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 0.2rem 0.5rem;
            border-radius: 999px;
            text-transform: uppercase;
        }

        .badge-blue {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .badge-green {
            background: #dcfce7;
            color: #166534;
        }

        .badge-red {
            background: #fee2e2;
            color: #991b1b;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.85rem 0.95rem;
            border: 1px solid #cfd8e3;
            border-radius: 10px;
            font: inherit;
            background: #fff;
            box-sizing: border-box;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #60a5fa;
            box-shadow: 0 0 0 0.2rem rgba(37, 99, 235, 0.12);
        }

        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }

        .help-text {
            display: block;
            margin-top: 0.35rem;
            color: #6c757d;
            font-size: 0.84rem;
            line-height: 1.5;
        }

        .calc-box {
            background: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 10px;
            padding: 1rem;
            margin-top: 0.3rem;
        }

        .calc-box strong {
            color: #1d4ed8;
        }

        .checkbox-box {
            border: 1px solid #f1d0d0;
            background: #fff8f8;
            border-radius: 10px;
            padding: 1rem;
        }

        .checkbox-row {
            display: flex;
            align-items: flex-start;
            gap: 0.7rem;
        }

        .checkbox-row input[type="checkbox"] {
            width: auto;
            margin-top: 0.2rem;
        }

        .modal-actions {
            margin-top: 1.5rem;
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .save-btn,
        .cancel-btn {
            border: none;
            border-radius: 10px;
            padding: 0.78rem 1.15rem;
            font: inherit;
            font-weight: 700;
            cursor: pointer;
        }

        .save-btn {
            background: #1d4ed8;
            color: white;
        }

        .save-btn:hover {
            background: #1e40af;
        }

        .cancel-btn {
            background: #e9ecef;
            color: #212529;
        }

        .cancel-btn:hover {
            background: #dfe3e6;
        }

        @media (max-width: 900px) {
            .bottom-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 760px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .page-header-row {
                align-items: flex-start;
            }
        }
    </style>
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
        <div class="page-wrap">
            <div class="page-header-row">
                <h2 class="page-title">Treatment Management</h2>
                <button type="button" class="top-action-btn" onclick="openModal()">
                    + Add Treatment
                </button>
            </div>

            <p class="page-subtitle">
                Record treatment details, calculate dosage from pond volume, store treatment history, and support quarantine workflows.
            </p>

            <%
                if (success != null) {
            %>
                <div class="alert-box alert-success"><%= success %></div>
            <%
                }
                if (error != null && !error.trim().isEmpty()) {
            %>
                <div class="alert-box alert-error"><%= error %></div>
            <%
                }
            %>

            <div class="content-card">
                <h3>Treatment Records</h3>
                <p class="muted-text">Stored treatment records with dosage, medication, duration, purpose, and quarantine status.</p>

                <div class="table-wrap">
                    <table class="treatment-table">
                        <thead>
                            <tr>
                                <th>Medication</th>
                                <th>Pond</th>
                                <th>Dosage</th>
                                <th>Duration</th>
                                <th>Purpose</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection con = null;
                                Statement stmt = null;
                                ResultSet rs = null;
                                boolean hasRows = false;

                                try {
                                    con = MysqlCon.getConnection();
                                    PreparedStatement pStmt = con.prepareStatement(
                                        "SELECT t.*, p.name AS pond_name " +
                                        "FROM treatments t " +
                                        "LEFT JOIN ponds p ON t.pond_id = p.id " +
                                        "WHERE p.organization_id = ? " +
                                        "ORDER BY t.created_at DESC"
                                    );
                                    pStmt.setInt(1, (Integer) session.getAttribute("orgId"));
                                    rs = pStmt.executeQuery();

                                    while (rs.next()) {
                                        hasRows = true;
                            %>
                            <tr>
                                <td><%= rs.getString("medication") %></td>
                                <td><%= rs.getString("pond_name") != null ? rs.getString("pond_name") : ("Pond " + rs.getInt("pond_id")) %></td>
                                <td><%= rs.getDouble("dosage") %> <%= rs.getString("dosage_unit") %></td>
                                <td><%= rs.getInt("duration") %> days</td>
                                <td><%= rs.getString("purpose") %></td>
                                <td>
                                    <span class="status-tag <%= rs.getBoolean("quarantine") ? "status-quarantine" : "status-active" %>">
                                        <%= rs.getBoolean("quarantine") ? "Quarantine" : "Active" %>
                                    </span>
                                </td>
                                <td>
                                    <a href="treatmentDetails.jsp?id=<%= rs.getInt("id") %>" class="table-btn">View</a>
                                </td>
                            </tr>
                            <%
                                    }

                                    if (!hasRows) {
                            %>
                            <tr>
                                <td colspan="7" style="text-align:center; color:#6c757d;">
                                    No treatment records yet. Click <strong>+ Add Treatment</strong> to create your first one.
                                </td>
                            </tr>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                            <tr>
                                <td colspan="7" style="color:#842029;">
                                    Error loading treatments: <%= e.getMessage() %>
                                </td>
                            </tr>
                            <%
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                                    if (con != null) try { con.close(); } catch (SQLException e) {}
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="bottom-grid">
                <div class="info-panel">
                    <div class="info-icon">🧮</div>
                    <h3>Dosing Calculator</h3>
                    <p>The form now supports pond-volume-based dosage calculation.</p>
                    <ul>
                        <li>Choose medication</li>
                        <li>Enter pond volume</li>
                        <li>Dosage auto-calculates</li>
                    </ul>
                </div>

                <div class="info-panel">
                    <div class="info-icon">⚠️</div>
                    <h3>Quarantine Support</h3>
                    <p>Marking a treatment as quarantine also marks the pond as quarantined for future transfer restrictions.</p>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

    <div id="treatmentModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-header">
                <h2>Create Treatment Record</h2>
                <div class="modal-sub">
                    Log treatment details and auto-calculate dosage based on pond volume.
                </div>
                <hr class="modal-divider">
            </div>

            <form action="treatments.jsp" method="post">
                <input type="hidden" name="action" value="create">
                <div class="form-section-title">Basic Info</div>

                <div class="form-grid">
                    <div class="form-group">
                        <label for="pondId">Pond</label>
                        <select id="pondId" name="pondId" required>
                            <option value="">Select a pond</option>
                            <%
                                Connection pondCon = null;
                                Statement pondStmt = null;
                                ResultSet pondRs = null;

                                try {
                                    pondCon = MysqlCon.getConnection();
                                    PreparedStatement pondPStmt = pondCon.prepareStatement("SELECT id, name FROM ponds WHERE organization_id = ? ORDER BY name");
                                    pondPStmt.setInt(1, (Integer) session.getAttribute("orgId"));
                                    pondRs = pondPStmt.executeQuery();

                                    while (pondRs.next()) {
                            %>
                                <option value="<%= pondRs.getInt("id") %>">
                                    <%= pondRs.getString("name") %> (ID: <%= pondRs.getInt("id") %>)
                                </option>
                            <%
                                    }
                                } catch (Exception e) {
                            %>
                                <option value="">Unable to load ponds</option>
                            <%
                                } finally {
                                    if (pondRs != null) try { pondRs.close(); } catch (SQLException e) {}
                                    if (pondStmt != null) try { pondStmt.close(); } catch (SQLException e) {}
                                    if (pondCon != null) try { pondCon.close(); } catch (SQLException e) {}
                                }
                            %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="userId">Recorded By User ID</label>
                        <input type="number" id="userId" name="userId" min="1" placeholder="e.g. 2" required>
                    </div>
                </div>

                <div class="form-section-title">Treatment Details</div>

                <div class="form-grid">
                    <div class="form-group">
                        <label for="medication">
                            <span>Medication</span>
                            <span class="field-badge badge-blue">Required</span>
                        </label>
                        <select id="medication" name="medication" onchange="calculateDosage()" required>
                            <option value="">Select medication</option>
                            <option value="Salt">Salt</option>
                            <option value="Praziquantel">Praziquantel</option>
                            <option value="Methylene Blue">Methylene Blue</option>
                        </select>
                        <span class="help-text">Choose medication to calculate dosage.</span>
                    </div>

                    <div class="form-group">
                        <label for="purpose">
                            <span>Purpose</span>
                            <span class="field-badge badge-blue">Required</span>
                        </label>
                        <input type="text" id="purpose" name="purpose" placeholder="e.g. Parasite treatment" required>
                    </div>

                    <div class="form-group">
                        <label for="pondVolume">
                            <span>Pond Volume</span>
                            <span class="field-badge badge-green">Calculator</span>
                        </label>
                        <input type="number" id="pondVolume" name="pondVolume" step="0.01" min="0" placeholder="e.g. 500" oninput="calculateDosage()" required>
                        <span class="help-text">Required for dosage calculation.</span>
                    </div>

                    <div class="form-group">
                        <label for="duration">
                            <span>Duration (days)</span>
                            <span class="field-badge badge-blue">Required</span>
                        </label>
                        <input type="number" id="duration" name="duration" min="1" required>
                    </div>

                    <div class="form-group">
                        <label for="dosage">
                            <span>Dosage</span>
                            <span class="field-badge badge-green">Auto</span>
                        </label>
                        <input type="number" id="dosage" name="dosage" step="0.01" min="0" readonly required>
                        <span class="help-text">Auto-calculated from medication + pond volume.</span>
                    </div>

                    <div class="form-group">
                        <label for="dosageUnit">
                            <span>Dosage Unit</span>
                            <span class="field-badge badge-green">Auto</span>
                        </label>
                        <select id="dosageUnit" name="dosageUnit">
                            <option value="kg">Kilograms</option>
                            <option value="g">Grams</option>
                            <option value="ml">Milliliters</option>
                            <option value="tbsp">Tablespoons</option>
                            <option value="tsp">Teaspoons</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <div class="calc-box">
                            <strong>Calculator guide:</strong><br>
                            Salt = pond volume × 0.003 kg<br>
                            Praziquantel = pond volume × 0.01 g<br>
                            Methylene Blue = pond volume × 0.05 ml
                        </div>
                    </div>

                    <div class="form-group full-width">
                        <label for="notes">Notes</label>
                        <textarea id="notes" name="notes" placeholder="Add treatment observations, instructions, or follow-up notes..."></textarea>
                    </div>

                    <div class="form-group full-width">
                        <div class="checkbox-box">
                            <div class="checkbox-row">
                                <input type="checkbox" id="quarantine" name="quarantine">
                                <div>
                                    <label for="quarantine" style="margin-bottom: 0.2rem;">Mark pond as quarantine</label>
                                    <div class="help-text">
                                        This also updates the pond quarantine status so koi transfers can be restricted from quarantined ponds.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="submit" class="save-btn">Save Treatment</button>
                    <button type="button" class="cancel-btn" onclick="closeModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() {
            document.getElementById("treatmentModal").style.display = "flex";
        }

        function closeModal() {
            document.getElementById("treatmentModal").style.display = "none";
        }

        function calculateDosage() {
            const medication = document.getElementById("medication").value;
            const pondVolume = parseFloat(document.getElementById("pondVolume").value);
            const dosageField = document.getElementById("dosage");
            const dosageUnitField = document.getElementById("dosageUnit");

            if (!medication || isNaN(pondVolume) || pondVolume <= 0) {
                dosageField.value = "";
                return;
            }

            let dosage = 0;
            let unit = "g";

            if (medication === "Salt") {
                dosage = pondVolume * 0.003;
                unit = "kg";
            } else if (medication === "Praziquantel") {
                dosage = pondVolume * 0.01;
                unit = "g";
            } else if (medication === "Methylene Blue") {
                dosage = pondVolume * 0.05;
                unit = "ml";
            }

            dosageField.value = dosage.toFixed(2);
            dosageUnitField.value = unit;
        }

        window.onclick = function(event) {
            const modal = document.getElementById("treatmentModal");
            if (event.target === modal) {
                closeModal();
            }
        };
    </script>
</body>
</html>