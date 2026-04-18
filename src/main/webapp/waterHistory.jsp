<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.koi.MysqlCon" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Water Test History</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        .page-top {
            margin-bottom: 2rem;
        }

        .page-top h2 {
            font-size: 1.6rem;
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

        .page-description {
            color: #6c757d;
            margin-top: 0.5rem;
        }

        .table-wrapper {
            overflow-x: auto;
            margin-top: 1rem;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
        }

        th, td {
            padding: 0.85rem 1rem;
            border-bottom: 1px solid #e9ecef;
            text-align: left;
            vertical-align: top;
        }

        th {
            background: #f8f9fa;
            font-weight: 700;
        }

        tr:hover {
            background: #f8f9fa;
        }

        .status-safe {
            color: #0f5132;
            font-weight: 700;
        }

        .status-warning {
            color: #664d03;
            font-weight: 700;
        }

        .status-danger {
            color: #842029;
            font-weight: 700;
        }

        .empty-box {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            color: #6c757d;
        }

        .button-row {
            margin-top: 1.5rem;
        }

        .back-button {
            display: inline-block;
            padding: 0.75rem 1.1rem;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            background: #0d6efd;
            color: white;
        }

        .back-button:hover {
            background: #0b5ed7;
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
        <div class="page-top">
            <div class="breadcrumbs">
                <a href="index.jsp">Dashboard</a> /
                <a href="waterTest.jsp">Water Quality</a> /
                Water Test History
            </div>
            <h2>Water Test History</h2>
            <p class="page-description">
                View previously logged pond water test records and monitor trends over time.
            </p>
        </div>

        <div class="section">
            <h2>Recorded Water Tests</h2>

            <%
                Connection con = null;
                Statement stmt = null;
                ResultSet rs = null;
                boolean hasRows = false;

                try {
                    con = MysqlCon.getConnection();
                    stmt = con.createStatement();
                    rs = stmt.executeQuery(
                        "SELECT wt.id, wt.pond_id, wt.user_id, wt.ph, wt.temperature, " +
                        "wt.ammonia, wt.nitrite, wt.nitrate, wt.notes, wt.created_at, " +
                        "p.name AS pond_name " +
                        "FROM water_tests wt " +
                        "LEFT JOIN ponds p ON wt.pond_id = p.id " +
                        "ORDER BY wt.created_at DESC"
                    );
            %>

            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Pond</th>
                            <th>Recorded By</th>
                            <th>pH</th>
                            <th>Temp (°F)</th>
                            <th>Ammonia</th>
                            <th>Nitrite</th>
                            <th>Nitrate</th>
                            <th>Status</th>
                            <th>Notes</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            while (rs.next()) {
                                hasRows = true;

                                double ph = rs.getDouble("ph");
                                double temperature = rs.getDouble("temperature");
                                double ammonia = rs.getDouble("ammonia");
                                double nitrite = rs.getDouble("nitrite");
                                double nitrate = rs.getDouble("nitrate");

                                String statusText = "Safe";
                                String statusClass = "status-safe";

                                if (ammonia >= 0.25 || nitrite >= 0.25 || nitrate >= 40) {
                                    statusText = "High Risk";
                                    statusClass = "status-danger";
                                } else if (ph < 6.5 || ph > 8.5 || temperature < 50 || temperature > 85) {
                                    statusText = "Warning";
                                    statusClass = "status-warning";
                                }
                        %>
                        <tr>
                            <td><%= rs.getTimestamp("created_at") %></td>
                            <td>
                                <%= rs.getString("pond_name") != null ? rs.getString("pond_name") : "Pond ID " + rs.getInt("pond_id") %>
                            </td>
                            <td>User <%= rs.getInt("user_id") %></td>
                            <td><%= ph %></td>
                            <td><%= temperature %></td>
                            <td><%= ammonia %></td>
                            <td><%= nitrite %></td>
                            <td><%= nitrate %></td>
                            <td class="<%= statusClass %>"><%= statusText %></td>
                            <td><%= rs.getString("notes") != null ? rs.getString("notes") : "" %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <%
                if (!hasRows) {
            %>
                <div class="empty-box">
                    No water test records found yet.
                </div>
            <%
                }
                } catch (Exception e) {
            %>
                <div class="empty-box">
                    Error loading water test history.
                </div>
            <%
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                    if (con != null) try { con.close(); } catch (SQLException e) {}
                }
            %>

            <div class="button-row">
                <a href="waterTest.jsp" class="back-button">← Back to Water Test Logging</a>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>
