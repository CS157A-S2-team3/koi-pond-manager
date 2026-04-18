<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatment Details</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        .page-wrap {
            max-width: 1000px;
            margin: 0 auto;
        }

        .page-top {
            margin-bottom: 1.5rem;
        }

        .breadcrumbs {
            font-size: 0.9rem;
            color: #6c757d;
            margin-bottom: 0.5rem;
        }

        .breadcrumbs a {
            color: inherit;
            text-decoration: none;
        }

        .details-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            padding: 1.6rem;
        }

        .details-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 1.5rem;
        }

        .details-title {
            margin: 0;
            font-size: 2rem;
        }

        .details-subtitle {
            margin-top: 0.4rem;
            color: #6c757d;
            line-height: 1.6;
        }

        .status-tag {
            display: inline-block;
            padding: 0.38rem 0.8rem;
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

        .section-block + .section-block {
            margin-top: 1.5rem;
            padding-top: 1.5rem;
            border-top: 1px solid #edf0f2;
        }

        .section-block h3 {
            margin-bottom: 1rem;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem 1.25rem;
        }

        .detail-item {
            background: #f8fafc;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 1rem;
        }

        .detail-label {
            font-size: 0.82rem;
            font-weight: 700;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            margin-bottom: 0.45rem;
        }

        .detail-value {
            color: #212529;
            line-height: 1.6;
            font-size: 1rem;
        }

        .notes-box {
            background: #f8fafc;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 1rem;
            line-height: 1.7;
            color: #212529;
        }

        .button-row {
            display: flex;
            gap: 0.8rem;
            margin-top: 1.5rem;
            flex-wrap: wrap;
        }

        .back-btn {
            display: inline-block;
            background: #e9ecef;
            color: #212529;
            text-decoration: none;
            padding: 0.8rem 1.15rem;
            border-radius: 8px;
            font-weight: 600;
        }

        .back-btn:hover {
            background: #dde2e6;
        }

        .error-box {
            background: #f8d7da;
            color: #842029;
            border: 1px solid #f1aeb5;
            border-radius: 8px;
            padding: 1rem;
        }

        @media (max-width: 720px) {
            .detail-grid {
                grid-template-columns: 1fr;
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
            <div class="page-top">
                <div class="breadcrumbs">
                    <a href="index.jsp">Dashboard</a> / <a href="treatments.jsp">Treatments</a> / Details
                </div>
            </div>

            <div class="details-card">
                <%
                    Connection con = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {
                        int id = Integer.parseInt(request.getParameter("id"));

                        con = MysqlCon.getConnection();
                        ps = con.prepareStatement(
                            "SELECT t.*, p.name AS pond_name " +
                            "FROM treatments t " +
                            "LEFT JOIN ponds p ON t.pond_id = p.id " +
                            "WHERE t.id = ?"
                        );
                        ps.setInt(1, id);
                        rs = ps.executeQuery();

                        if (rs.next()) {
                            boolean quarantine = rs.getBoolean("quarantine");
                %>
                    <div class="details-header">
                        <div>
                            <h2 class="details-title"><%= rs.getString("medication") %></h2>
                            <div class="details-subtitle">
                                Treatment record for
                                <strong><%= rs.getString("pond_name") != null ? rs.getString("pond_name") : ("Pond " + rs.getInt("pond_id")) %></strong>
                            </div>
                        </div>

                        <div>
                            <span class="status-tag <%= quarantine ? "status-quarantine" : "status-active" %>">
                                <%= quarantine ? "Quarantine" : "Active" %>
                            </span>
                        </div>
                    </div>

                    <div class="section-block">
                        <h3>Overview</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <div class="detail-label">Treatment ID</div>
                                <div class="detail-value"><%= rs.getInt("id") %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Purpose</div>
                                <div class="detail-value"><%= rs.getString("purpose") %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Pond</div>
                                <div class="detail-value">
                                    <%= rs.getString("pond_name") != null ? rs.getString("pond_name") : ("Pond " + rs.getInt("pond_id")) %>
                                </div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Recorded By User ID</div>
                                <div class="detail-value"><%= rs.getInt("user_id") %></div>
                            </div>
                        </div>
                    </div>

                    <div class="section-block">
                        <h3>Dosage Details</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <div class="detail-label">Dosage</div>
                                <div class="detail-value"><%= rs.getDouble("dosage") %> <%= rs.getString("dosage_unit") %></div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Duration</div>
                                <div class="detail-value"><%= rs.getInt("duration") %> days</div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Pond Volume</div>
                                <div class="detail-value">
                                    <%= rs.getObject("pond_volume") != null ? rs.getDouble("pond_volume") : "Not provided" %>
                                </div>
                            </div>

                            <div class="detail-item">
                                <div class="detail-label">Created At</div>
                                <div class="detail-value"><%= rs.getTimestamp("created_at") %></div>
                            </div>
                        </div>
                    </div>

                    <div class="section-block">
                        <h3>Notes</h3>
                        <div class="notes-box">
                            <%= rs.getString("notes") != null && !rs.getString("notes").trim().isEmpty() ? rs.getString("notes") : "No notes provided." %>
                        </div>
                    </div>
                <%
                        } else {
                %>
                    <div class="error-box">Treatment record not found.</div>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <div class="error-box">Error: <%= e.getMessage() %></div>
                <%
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                        if (con != null) try { con.close(); } catch (SQLException e) {}
                    }
                %>

                <div class="button-row">
                    <a href="treatments.jsp" class="back-btn">← Back to Treatments</a>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>
