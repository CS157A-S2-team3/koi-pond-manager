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
    <title>Water Test History</title>
    <link rel="stylesheet" href="css/style.css">


<style>
    .page-top { margin-bottom: 2rem; }
    .breadcrumbs { font-size: 0.9rem; color: #6c757d; margin-bottom: 0.5rem; }
    .page-description { color: #6c757d; margin-top: 0.5rem; }
    .table-wrapper { overflow-x: auto; margin-top: 1rem; }

    table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
    }

    th, td {
        padding: 0.85rem 1rem;
        border-bottom: 1px solid #e9ecef;
    }

    th {
        background: #f8f9fa;
        font-weight: 700;
    }

    .status-safe { color: #0f5132; font-weight: 700; }
    .status-warning { color: #664d03; font-weight: 700; }
    .status-danger { color: #842029; font-weight: 700; }

    .empty-box {
        background: #f8f9fa;
        border: 1px solid #e9ecef;
        padding: 1rem;
    }
</style>


</head>

<body>

<%@ include file="header.jsp" %>

<main>

<h2>Water Test History</h2>

<%
Connection con = null;
PreparedStatement pStmt = null;
ResultSet rs = null;
boolean hasRows = false;

try {
con = MysqlCon.getConnection();


pStmt = con.prepareStatement(
    "SELECT wt.*, p.name AS pond_name, u.full_name, u.role " +
    "FROM water_tests wt " +
    "LEFT JOIN ponds p ON wt.pond_id = p.id " +
    "LEFT JOIN users u ON wt.user_id = u.id " +
    "WHERE p.organization_id = ? " +
    "ORDER BY wt.created_at DESC"
);

pStmt.setInt(1, (Integer) session.getAttribute("orgId"));
rs = pStmt.executeQuery();


%>

<table>
<tr>
    <th>Date</th>
    <th>Pond</th>
    <th>Recorded By</th>
    <th>pH</th>
    <th>Temp</th>
    <th>Ammonia</th>
    <th>Nitrite</th>
    <th>Nitrate</th>
    <th>Status</th>
    <th>Notes</th>
</tr>

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

if (ammonia >= 0.25 || nitrite >= 0.25 || nitrate >= 40 || temperature < 45 || temperature > 90) {
    statusText = "High Risk";
    statusClass = "status-danger";
} else if (ph < 6.5 || ph > 8.5 || temperature < 50 || temperature > 85) {
    statusText = "Warning";
    statusClass = "status-warning";
}


%>

<tr>
<td><%= rs.getTimestamp("created_at") %></td>

<td><%= rs.getString("pond_name") %></td>

<td>
<%= rs.getString("full_name") != null ? rs.getString("full_name") : "Unknown User" %>
(<%= rs.getString("role") != null ? rs.getString("role") : "N/A" %>)
</td>

<td><%= ph %></td>
<td><%= temperature %></td>
<td><%= ammonia %></td>
<td><%= nitrite %></td>
<td><%= nitrate %></td>

<td class="<%= statusClass %>"><%= statusText %></td>

<td><%= rs.getString("notes") %></td>

</tr>

<%
}
%>

</table>

<%
if (!hasRows) {
%>

<div class="empty-box">No records yet</div>
<%
}
} catch (Exception e) {
%>
<div class="empty-box">Error loading data</div>
<%
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pStmt != null) try { pStmt.close(); } catch (Exception e) {}
    if (con != null) try { con.close(); } catch (Exception e) {}
}
%>

</main>

</body>
</html>
