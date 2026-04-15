<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatment Management</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        .page-wrap {
            max-width: 1200px;
            margin: 0 auto;
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
        }

        .page-subtitle {
            color: #6c757d;
            margin: 0 0 1.5rem 0;
            line-height: 1.6;
        }

        .top-action-btn {
            background: #4a90e2;
            color: white;
            border: none;
            border-radius: 999px;
            padding: 0.9rem 1.4rem;
            font: inherit;
            font-weight: 600;
            cursor: pointer;
        }

        .top-action-btn:hover {
            background: #357bd8;
        }

        .alert-box {
            border-radius: 8px;
            padding: 0.9rem 1rem;
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
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .content-card h3 {
            margin-bottom: 0.4rem;
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
            background: #dceaf8;
            padding: 1rem;
            font-size: 1rem;
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
            background: #4a90e2;
            color: white;
            border: none;
            border-radius: 6px;
            padding: 0.55rem 0.9rem;
            font: inherit;
            font-weight: 600;
            cursor: pointer;
        }

        .table-btn:hover {
            background: #357bd8;
        }

        .bottom-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
        }

        .info-panel {
            background: #dceaf8;
            border: 1px solid #4a90e2;
            border-radius: 10px;
            padding: 2rem 1.5rem;
            text-align: center;
            min-height: 220px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .info-icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: #1f70d1;
        }

        .info-panel h3 {
            margin-bottom: 0.8rem;
            font-size: 1.5rem;
        }

        .info-panel p {
            margin: 0;
            font-size: 1.2rem;
            color: #374151;
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
            max-width: 680px;
            border-radius: 14px;
            padding: 2rem;
            border: 1px solid #e5e7eb;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
            max-height: 90vh;
            overflow-y: auto;
        }

        .modal-header {
            text-align: center;
            margin-bottom: 1.5rem;
        }

        .modal-header h2 {
            margin: 0 0 0.75rem 0;
            color: #1f70d1;
            font-size: 2rem;
        }

        .modal-divider {
            border: none;
            border-top: 2px solid #dceaf8;
            margin: 0;
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
            display: block;
            font-weight: 700;
            margin-bottom: 0.45rem;
            font-size: 1rem;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.85rem 0.95rem;
            border: 1px solid #bfc8d2;
            border-radius: 8px;
            font: inherit;
            background: #fff;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #4a90e2;
            box-shadow: 0 0 0 0.2rem rgba(74, 144, 226, 0.18);
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

        .checkbox-box {
            border: 1px solid #f1d0d0;
            background: #fff8f8;
            border-radius: 8px;
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
            border-radius: 8px;
            padding: 0.75rem 1.15rem;
            font: inherit;
            font-weight: 600;
            cursor: pointer;
        }

        .save-btn {
            background: #1f70d1;
            color: white;
        }

        .save-btn:hover {
            background: #155db6;
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
                Record treatment details, keep track of medication plans, and prepare for dosing support and quarantine-related actions.
            </p>

            <%
                String success = request.getParameter("success");
                String error = request.getParameter("error");
                if ("1".equals(success)) {
            %>
                <div class="alert-box alert-success">Treatment added successfully.</div>
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
                <p class="muted-text">Stored treatment records for ponds and future treatment history tracking.</p>

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
                                    stmt = con.createStatement();
                                    rs = stmt.executeQuery("SELECT t.*, p.name AS pond_name FROM treatments t LEFT JOIN ponds p ON t.pond_id = p.id ORDER BY t.created_at DESC");

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
        <a href="treatmentDetails.jsp?id=<%= rs.getInt("id") %>" class="table-btn" style="text-decoration:none; display:inline-block;">
        View
        </a>
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
                    <p>Prepared for pond-volume-based treatment calculations.</p>
                </div>

                <div class="info-panel">
                    <div class="info-icon">⚠️</div>
                    <h3>Quarantine Rules</h3>
                    <p>Supports future quarantine marking and transfer restrictions.</p>
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
                <hr class="modal-divider">
            </div>

            <form action="treatment" method="post">
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
                                    pondStmt = pondCon.createStatement();
                                    pondRs = pondStmt.executeQuery("SELECT id, name FROM ponds ORDER BY name");

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
                        <input type="number" id="userId" name="userId" min="1" placeholder="e.g., 2" required>
                    </div>

                    <div class="form-group">
                        <label for="medication">Medication</label>
                        <input type="text" id="medication" name="medication" placeholder="e.g., Salt" required>
                    </div>

                    <div class="form-group">
                        <label for="purpose">Purpose</label>
                        <input type="text" id="purpose" name="purpose" placeholder="e.g., Parasite treatment" required>
                    </div>

                    <div class="form-group">
                        <label for="dosage">Dosage</label>
                        <input type="number" id="dosage" name="dosage" step="0.01" min="0" required>
                    </div>

                    <div class="form-group">
                        <label for="dosageUnit">Dosage Unit</label>
                        <select id="dosageUnit" name="dosageUnit">
                            <option value="kg">Kilograms</option>
                            <option value="g">Grams</option>
                            <option value="ml">Milliliters</option>
                            <option value="tbsp">Tablespoons</option>
                            <option value="tsp">Teaspoons</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="duration">Duration (days)</label>
                        <input type="number" id="duration" name="duration" min="1" required>
                    </div>

                    <div class="form-group">
                        <label for="pondVolume">Pond Volume</label>
                        <input type="number" id="pondVolume" name="pondVolume" step="0.01" min="0" placeholder="Optional">
                    </div>

                    <div class="form-group full-width">
                        <label for="notes">Notes</label>
                        <textarea id="notes" name="notes" placeholder="Add treatment observations or instructions..."></textarea>
                    </div>

                    <div class="form-group full-width">
                        <div class="checkbox-box">
                            <div class="checkbox-row">
                                <input type="checkbox" id="quarantine" name="quarantine">
                                <div>
                                    <label for="quarantine" style="margin-bottom: 0.2rem;">Mark pond as quarantine</label>
                                    <div class="help-text">Prepared for future restriction of koi transfers from quarantined ponds.</div>
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

        window.onclick = function(event) {
            const modal = document.getElementById("treatmentModal");
            if (event.target === modal) {
                closeModal();
            }
        };
    </script>
</body>
</html>
