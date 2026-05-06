<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
<%@ page import="java.net.URLEncoder" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection waterCon = null;
        try {
            int orgId = (Integer) session.getAttribute("orgId");
            int userId = (Integer) session.getAttribute("userId");

            int pondId;
            double ph, temperature, ammonia, nitrite, nitrate;
            String notes;
            try {
                pondId = Integer.parseInt(request.getParameter("pondId"));
                ph = Double.parseDouble(request.getParameter("ph"));
                temperature = Double.parseDouble(request.getParameter("temperature"));
                ammonia = Double.parseDouble(request.getParameter("ammonia"));
                nitrite = Double.parseDouble(request.getParameter("nitrite"));
                nitrate = Double.parseDouble(request.getParameter("nitrate"));
                notes = request.getParameter("notes");
            } catch (NumberFormatException e) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Please enter valid numeric values.", "UTF-8"));
                return;
            }

            if (pondId <= 0) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Please select a valid pond.", "UTF-8"));
                return;
            }
            if (ph < 0 || ph > 14) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("pH must be between 0 and 14.", "UTF-8"));
                return;
            }
            if (temperature < 32 || temperature > 120) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Temperature must be between 32 and 120.", "UTF-8"));
                return;
            }
            if (ammonia < 0 || nitrite < 0 || nitrate < 0) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Ammonia, nitrite, and nitrate cannot be negative.", "UTF-8"));
                return;
            }

            waterCon = MysqlCon.getConnection();

            PreparedStatement verifyPs = waterCon.prepareStatement(
                "SELECT id FROM ponds WHERE id = ? AND organization_id = ?");
            verifyPs.setInt(1, pondId);
            verifyPs.setInt(2, orgId);
            ResultSet verifyRs = verifyPs.executeQuery();
            boolean pondValid = verifyRs.next();
            verifyRs.close();
            verifyPs.close();
            if (!pondValid) {
                response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Invalid pond selection.", "UTF-8"));
                return;
            }

            PreparedStatement ps = waterCon.prepareStatement(
                "INSERT INTO water_tests (pond_id, user_id, ph, temperature, ammonia, nitrite, nitrate, notes) "
              + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            ps.setInt(1, pondId);
            ps.setInt(2, userId);
            ps.setDouble(3, ph);
            ps.setDouble(4, temperature);
            ps.setDouble(5, ammonia);
            ps.setDouble(6, nitrite);
            ps.setDouble(7, nitrate);
            ps.setString(8, notes);
            ps.executeUpdate();
            ps.close();

            StringBuilder warning = new StringBuilder();
            if (ph < 6.5 || ph > 8.5) warning.append("pH is outside the recommended range (6.5-8.5). ");
            if (ammonia >= 0.25) warning.append("Ammonia is above the recommended threshold (< 0.25). ");
            if (nitrite >= 0.25) warning.append("Nitrite is above the recommended threshold (< 0.25). ");
            if (nitrate >= 40) warning.append("Nitrate is above the recommended threshold (< 40). ");
            if (temperature < 50 || temperature > 85) warning.append("Temperature is outside the typical koi-safe range (50-85°F). ");

            if (warning.length() > 0) {
                response.sendRedirect("waterTest.jsp?success=1&warning=" + URLEncoder.encode(warning.toString(), "UTF-8"));
            } else {
                response.sendRedirect("waterTest.jsp?success=1");
            }
            return;

        } catch (Exception e) {
            response.sendRedirect("waterTest.jsp?error=" + URLEncoder.encode("Database error while saving water test.", "UTF-8"));
            return;
        } finally {
            if (waterCon != null) try { waterCon.close(); } catch (Exception e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Water Quality Logging</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        body {
            background: #f5f7fb;
        }

        .page-shell {
            max-width: 1300px;
            margin: 0 auto;
            padding: 2rem 1.5rem 3rem;
        }

        .page-top {
            margin-bottom: 1.75rem;
        }

        .page-top h2 {
            font-size: 2rem;
            margin-bottom: 0.4rem;
            color: #1f2937;
        }

        .breadcrumbs {
            font-size: 0.92rem;
            color: #6b7280;
            margin-bottom: 0.6rem;
        }

        .breadcrumbs a {
            color: inherit;
            text-decoration: none;
        }

        .breadcrumbs a:hover {
            text-decoration: underline;
        }

        .page-description {
            color: #6b7280;
            margin-top: 0.3rem;
            font-size: 1rem;
        }

        .alert-box {
            border-radius: 12px;
            padding: 1rem 1.1rem;
            margin: 1rem 0 0.75rem 0;
            font-weight: 600;
            box-shadow: 0 8px 20px rgba(15, 23, 42, 0.04);
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

        .alert-warning {
            background: #fff3cd;
            color: #664d03;
            border: 1px solid #ffecb5;
        }

        .summary-cards {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 1rem;
            margin-bottom: 1.75rem;
        }

        .card {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            padding: 1rem 1.1rem;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }

        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 14px 28px rgba(15, 23, 42, 0.08);
        }

        .card-label {
            font-size: 0.78rem;
            color: #6b7280;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: 0.04em;
            margin-bottom: 0.5rem;
        }

        .card-value {
            font-size: 2rem;
            font-weight: 800;
            color: #1f2937;
            line-height: 1.1;
        }

        .card-sub {
            margin-top: 0.35rem;
            color: #6b7280;
            font-size: 0.9rem;
        }

        .card-icon {
            font-size: 1.15rem;
            margin-right: 0.35rem;
        }

        .content-layout {
            display: grid;
            grid-template-columns: minmax(0, 2fr) minmax(290px, 0.9fr);
            gap: 1.5rem;
            align-items: start;
        }

        .section {
            background: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 18px;
            padding: 1.2rem 1.2rem 1.35rem;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.04);
        }

        .section h2 {
            margin: 0 0 0.4rem;
            font-size: 1.3rem;
            color: #1f2937;
        }

        .section-subtitle {
            color: #6b7280;
            margin-bottom: 1rem;
        }

        .note-box {
            background: linear-gradient(135deg, #eff6ff, #f8fbff);
            border: 1px solid #bfdbfe;
            border-left: 5px solid #2563eb;
            padding: 1rem;
            border-radius: 12px;
            margin: 1rem 0 1.3rem 0;
            color: #334155;
        }

        .status-strip {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 0.9rem;
            margin-bottom: 1.2rem;
        }

        .status-pill-box {
            border-radius: 14px;
            padding: 0.9rem 1rem;
            border: 1px solid #e5e7eb;
            background: #fafafa;
        }

        .status-pill-box h3 {
            margin: 0 0 0.4rem;
            font-size: 0.92rem;
            color: #1f2937;
        }

        .status-pill-box p {
            margin: 0;
            color: #6b7280;
            font-size: 0.86rem;
        }

        .safe-bg {
            background: #f0fdf4;
            border-color: #bbf7d0;
        }

        .warn-bg {
            background: #fffbeb;
            border-color: #fde68a;
        }

        .danger-bg {
            background: #fef2f2;
            border-color: #fecaca;
        }

        .form-section-title {
            font-size: 0.95rem;
            font-weight: 800;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin: 1.15rem 0 0.8rem;
            padding-top: 0.2rem;
        }

        .form-layout {
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
            margin-bottom: 0.42rem;
            color: #374151;
            font-size: 0.96rem;
        }

        .field-badge {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 0.2rem 0.5rem;
            border-radius: 999px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        .badge-green {
            background: #dcfce7;
            color: #166534;
        }

        .badge-yellow {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-red {
            background: #fee2e2;
            color: #991b1b;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.86rem 0.9rem;
            border: 1px solid #d1d5db;
            border-radius: 12px;
            font: inherit;
            background: #ffffff;
            transition: border-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
            box-sizing: border-box;
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: #60a5fa;
            box-shadow: 0 0 0 0.22rem rgba(37, 99, 235, 0.12);
        }

        .form-group input:hover,
        .form-group textarea:hover,
        .form-group select:hover {
            border-color: #9ca3af;
        }

        .input-green {
            border-left: 4px solid #22c55e !important;
        }

        .input-yellow {
            border-left: 4px solid #f59e0b !important;
        }

        .input-red {
            border-left: 4px solid #ef4444 !important;
        }

        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }

        .help-text {
            display: block;
            margin-top: 0.38rem;
            font-size: 0.82rem;
            color: #6b7280;
        }

        .button-row {
            display: flex;
            gap: 0.8rem;
            margin-top: 1.35rem;
            flex-wrap: wrap;
        }

        .main-button,
        .cancel-button,
        .history-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.82rem 1.15rem;
            border-radius: 12px;
            border: none;
            font: inherit;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            transition: transform 0.18s ease, box-shadow 0.18s ease, background 0.18s ease;
        }

        .main-button:hover,
        .cancel-button:hover,
        .history-button:hover {
            transform: translateY(-1px);
        }

        .main-button {
            background: #2563eb;
            color: white;
            box-shadow: 0 10px 18px rgba(37, 99, 235, 0.18);
        }

        .main-button:hover {
            background: #1d4ed8;
        }

        .cancel-button {
            background: #e5e7eb;
            color: #111827;
        }

        .cancel-button:hover {
            background: #d1d5db;
        }

        .history-button {
            background: #ffffff;
            color: #2563eb;
            border: 1px solid #bfdbfe;
        }

        .history-button:hover {
            background: #eff6ff;
        }

        .range-list {
            display: grid;
            gap: 0.8rem;
            margin-top: 0.25rem;
        }

        .range-box {
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            padding: 1rem;
            background: #ffffff;
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }

        .range-box:hover {
            transform: translateY(-1px);
            box-shadow: 0 10px 18px rgba(15, 23, 42, 0.05);
        }

        .range-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.45rem;
            gap: 0.5rem;
        }

        .range-name {
            font-weight: 800;
            color: #1f2937;
        }

        .range-text {
            margin: 0;
            font-size: 0.92rem;
            color: #6b7280;
        }

        .tag {
            font-size: 0.7rem;
            font-weight: 800;
            padding: 0.28rem 0.58rem;
            border-radius: 999px;
            text-transform: uppercase;
            letter-spacing: 0.03em;
        }

        .green {
            background: #d1fae5;
            color: #065f46;
        }

        .yellow {
            background: #fef3c7;
            color: #92400e;
        }

        .red {
            background: #fee2e2;
            color: #991b1b;
        }

        .small-note {
            margin-top: 1rem;
            font-size: 0.85rem;
            color: #6b7280;
            line-height: 1.5;
        }

        @media (max-width: 1100px) {
            .summary-cards {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 950px) {
            .content-layout {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 700px) {
            .summary-cards,
            .status-strip,
            .form-layout {
                grid-template-columns: 1fr;
            }

            .page-shell {
                padding: 1.3rem 1rem 2.5rem;
            }

            .page-top h2 {
                font-size: 1.6rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <div class="page-shell">
        <main>
            <div class="page-top">
                <div class="breadcrumbs">
                    <a href="index.jsp">Dashboard</a> / Water Quality / Log Test
                </div>
                <h2>Water Quality Logging</h2>
                <p class="page-description">
                    Record pond test readings, review safe water ranges, and quickly spot values that may need attention.
                </p>

                <%
                    String success = request.getParameter("success");
                    String error = request.getParameter("error");
                    String warning = request.getParameter("warning");

                    if ("1".equals(success)) {
                %>
                    <div class="alert-box alert-success">Water test logged successfully.</div>
                <%
                    }
                    if (warning != null && !warning.trim().isEmpty()) {
                %>
                    <div class="alert-box alert-warning"><%= warning %></div>
                <%
                    }
                    if (error != null && !error.trim().isEmpty()) {
                %>
                    <div class="alert-box alert-error"><%= error %></div>
                <%
                    }
                %>
            </div>

            <div class="content-layout">
                <div class="section">
                    <h2>Water Test Entry</h2>
                    <p class="section-subtitle">Enter the latest pond readings below.</p>

                    <div class="status-strip">
                        <div class="status-pill-box safe-bg">
                            <h3>Ideal Zone</h3>
                            <p>Healthy readings that support stable pond conditions.</p>
                        </div>
                        <div class="status-pill-box warn-bg">
                            <h3>Monitor Closely</h3>
                            <p>Values slightly outside the recommended range.</p>
                        </div>
                        <div class="status-pill-box danger-bg">
                            <h3>Needs Attention</h3>
                            <p>High-risk values that may require quick action.</p>
                        </div>
                    </div>

                    <div class="note-box">
                        Values outside the recommended range can still be recorded. This helps preserve accurate historical logs while also flagging readings that need follow-up.
                    </div>

                    <form action="waterTest.jsp" method="post">
                        <div class="form-section-title">Basic Info</div>

                        <div class="form-layout">
                            <div class="form-group full-width">
                                <label for="pondId">Pond</label>
                                <select id="pondId" name="pondId" required>
                                    <option value="">Select a pond</option>
                                    <%
                                        Connection pondCon = null;
                                        Statement pondStmt = null;
                                        ResultSet pondRs = null;

                                        try {
                                            pondCon = MysqlCon.getConnection();
                                            PreparedStatement pondPStmt = pondCon.prepareStatement("SELECT id, code FROM ponds WHERE organization_id = ? ORDER BY code");
                                            pondPStmt.setInt(1, (Integer) session.getAttribute("orgId"));
                                            pondRs = pondPStmt.executeQuery();

                                            while (pondRs.next()) {
                                    %>
                                        <option value="<%= pondRs.getInt("id") %>">
                                            <%= pondRs.getString("code") %>
                                        </option>
                                    <%
                                            }
                                        } catch (Exception e) {
                                    %>
                                        <option value="">Error loading ponds</option>
                                    <%
                                        } finally {
                                            if (pondRs != null) try { pondRs.close(); } catch (SQLException e) {}
                                            if (pondStmt != null) try { pondStmt.close(); } catch (SQLException e) {}
                                            if (pondCon != null) try { pondCon.close(); } catch (SQLException e) {}
                                        }
                                    %>
                                </select>
                                <span class="help-text">Select the pond this reading belongs to.</span>
                            </div>
                        </div>

                        <div class="form-section-title">Water Readings</div>

                        <div class="form-layout">
                            <div class="form-group">
                                <label for="ph">
                                    <span>pH</span>
                                    <span class="field-badge badge-green">Ideal</span>
                                </label>
                                <input type="number" id="ph" name="ph" class="input-green" step="0.01" min="0" max="14" placeholder="e.g. 7.40" required>
                                <span class="help-text">Valid: 0–14 | Recommended: 6.5–8.5</span>
                            </div>

                            <div class="form-group">
                                <label for="temperature">
                                    <span>Temperature (°F)</span>
                                    <span class="field-badge badge-green">Seasonal</span>
                                </label>
                                <input type="number" id="temperature" name="temperature" class="input-green" step="0.01" min="32" max="120" placeholder="e.g. 72" required>
                                <span class="help-text">Valid: 32–120 | Typical safe range: 50–85°F</span>
                            </div>

                            <div class="form-group">
                                <label for="ammonia">
                                    <span>Ammonia</span>
                                    <span class="field-badge badge-red">High Risk</span>
                                </label>
                                <input type="number" id="ammonia" name="ammonia" class="input-red" step="0.01" min="0" placeholder="e.g. 0.10" required>
                                <span class="help-text">Recommended: under 0.25</span>
                            </div>

                            <div class="form-group">
                                <label for="nitrite">
                                    <span>Nitrite</span>
                                    <span class="field-badge badge-yellow">Monitor</span>
                                </label>
                                <input type="number" id="nitrite" name="nitrite" class="input-yellow" step="0.01" min="0" placeholder="e.g. 0.05" required>
                                <span class="help-text">Recommended: under 0.25</span>
                            </div>

                            <div class="form-group full-width">
                                <label for="nitrate">
                                    <span>Nitrate</span>
                                    <span class="field-badge badge-yellow">Trend</span>
                                </label>
                                <input type="number" id="nitrate" name="nitrate" class="input-yellow" step="0.01" min="0" placeholder="e.g. 20.00" required>
                                <span class="help-text">Recommended: under 40</span>
                            </div>
                        </div>

                        <div class="form-section-title">Notes</div>

                        <div class="form-layout">
                            <div class="form-group full-width">
                                <label for="notes">Observations</label>
                                <textarea id="notes" name="notes" placeholder="Add koi behavior, maintenance observations, or anything unusual you noticed..."></textarea>
                                <span class="help-text">Optional</span>
                            </div>
                        </div>

                        <div class="button-row">
                            <button type="submit" class="main-button">Submit Water Test</button>
                            <a href="index.jsp" class="cancel-button">Cancel</a>
                            <a href="waterHistory.jsp" class="history-button">View Water Test History →</a>
                        </div>
                    </form>
                </div>

                <div class="section">
                    <h2>Recommended Ranges</h2>
                    <p class="section-subtitle">Quick reference for common pond readings.</p>

                    <div class="range-list">
                        <div class="range-box">
                            <div class="range-top">
                                <div class="range-name">pH</div>
                                <span class="tag green">Ideal</span>
                            </div>
                            <p class="range-text">Recommended: 6.5–8.5</p>
                        </div>

                        <div class="range-box">
                            <div class="range-top">
                                <div class="range-name">Ammonia</div>
                                <span class="tag red">High Risk</span>
                            </div>
                            <p class="range-text">Target: below 0.25</p>
                        </div>

                        <div class="range-box">
                            <div class="range-top">
                                <div class="range-name">Nitrite</div>
                                <span class="tag yellow">Monitor</span>
                            </div>
                            <p class="range-text">Keep below 0.25</p>
                        </div>

                        <div class="range-box">
                            <div class="range-top">
                                <div class="range-name">Nitrate</div>
                                <span class="tag yellow">Trend</span>
                            </div>
                            <p class="range-text">Keep below 40</p>
                        </div>

                        <div class="range-box">
                            <div class="range-top">
                                <div class="range-name">Temperature</div>
                                <span class="tag green">Seasonal</span>
                            </div>
                            <p class="range-text">Typical koi-safe range: 50–85°F</p>
                        </div>
                    </div>

                    <p class="small-note">
                        These ranges are general guide values. Logging all test results, including borderline ones, helps with long-term pond health tracking.
                    </p>
                </div>
            </div>
        </main>
    </div>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>
