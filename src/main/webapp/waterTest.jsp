<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
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

            <div class="summary-cards">
                <div class="card">
                    <div class="card-label"><span class="card-icon">🧪</span>pH Target</div>
                    <div class="card-value">6.5–8.5</div>
                    <div class="card-sub">Ideal pond balance</div>
                </div>

                <div class="card">
                    <div class="card-label"><span class="card-icon">⚠️</span>Ammonia</div>
                    <div class="card-value">&lt; 0.25</div>
                    <div class="card-sub">Keep very low</div>
                </div>

                <div class="card">
                    <div class="card-label"><span class="card-icon">📈</span>Nitrite / Nitrate</div>
                    <div class="card-value">&lt; 0.25 / &lt; 40</div>
                    <div class="card-sub">Track changes over time</div>
                </div>

                <div class="card">
                    <div class="card-label"><span class="card-icon">🌡️</span>Temperature</div>
                    <div class="card-value">50–85°F</div>
                    <div class="card-sub">Typical koi-safe range</div>
                </div>
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

                    <form action="waterTest" method="post">
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
