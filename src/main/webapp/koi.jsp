<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon, java.text.SimpleDateFormat" %>

<%!
    // Java helper method: escapes special HTML characters
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    // Java helper method: returns "N/A" if the string is null, otherwise returns the string
    private String orNA(String s) {
        return (s != null && !s.isEmpty()) ? s : "N/A";
    }
%>

<%
    // Check if a koi card was clicked (selectedId passed via URL)
    String selectedIdParam = request.getParameter("selectedId");
    int selectedId = -1;
    if (selectedIdParam != null) {
        try { selectedId = Integer.parseInt(selectedIdParam); } catch (NumberFormatException e) {}
    }

    // Variables to hold the selected koi's data for the modal
    String modalName = "", modalVariety = "N/A", modalBreeder = "N/A", modalSex = "N/A";
    String modalAge = "N/A", modalSize = "N/A", modalPond = "None", modalStatus = "N/A";
    String modalDeceased = "";
    String modalNotes = "";
    String modalHistoryHtml = "<p class=\"koi-history-empty\">No pond transfers recorded.</p>";
    boolean showModal = false;

    if (selectedId > 0) {
        java.sql.Connection modalCon = null;
        try {
            modalCon = MysqlCon.getConnection();

            // Query the selected koi's details
            PreparedStatement modalPs = modalCon.prepareStatement("SELECT * FROM koi WHERE id = ?");
            modalPs.setInt(1, selectedId);
            ResultSet modalRs = modalPs.executeQuery();

            if (modalRs.next()) {
                showModal = true;
                modalName    = orNA(modalRs.getString("name"));
                modalVariety = orNA(modalRs.getString("variety"));
                modalBreeder = orNA(modalRs.getString("breeder"));
                modalSex     = orNA(modalRs.getString("sex"));

                int mAge = modalRs.getInt("age");       boolean mAgeNull  = modalRs.wasNull();
                double mSize = modalRs.getDouble("size_cm"); boolean mSizeNull = modalRs.wasNull();
                int mPondId  = modalRs.getInt("pond_id");    boolean mPondNull = modalRs.wasNull();

                modalStatus = orNA(modalRs.getString("status"));
                modalAge    = mAgeNull  ? "N/A" : String.valueOf(mAge);
                modalSize   = mSizeNull ? "N/A" : String.format("%.2f", mSize) + " cm";
                modalPond   = mPondNull ? "None" : String.valueOf(mPondId);

                java.sql.Timestamp mUpdatedAt = modalRs.getTimestamp("updated_at");
                SimpleDateFormat dtf = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
                if ("deceased".equals(modalStatus) && mUpdatedAt != null) {
                    modalDeceased = dtf.format(mUpdatedAt);
                }

                modalNotes = modalRs.getString("notes") != null ? modalRs.getString("notes") : "";

                // Query and build the pond history table for the selected koi
                PreparedStatement histPs = modalCon.prepareStatement(
                    "SELECT kph.moved_at, " +
                    "(SELECT p.name FROM ponds p WHERE p.id = kph.from_pond_id) AS from_name, " +
                    "(SELECT p.name FROM ponds p WHERE p.id = kph.to_pond_id) AS to_name " +
                    "FROM koi_pond_history kph " +
                    "WHERE kph.koi_id = ? ORDER BY kph.moved_at ASC");
                histPs.setInt(1, selectedId);
                ResultSet histRs = histPs.executeQuery();
                SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                StringBuilder histRows = new StringBuilder();
                boolean hasHistory = false;
                while (histRs.next()) {
                    hasHistory = true;
                    String fromName = histRs.getString("from_name") != null ? histRs.getString("from_name") : "None";
                    String toName   = histRs.getString("to_name")   != null ? histRs.getString("to_name")   : "None";
                    String movedAt  = sdf.format(histRs.getTimestamp("moved_at"));
                    histRows.append("<tr><td>").append(movedAt).append("</td>")
                            .append("<td>").append(escapeHtml(fromName)).append("</td>")
                            .append("<td>").append(escapeHtml(toName)).append("</td></tr>");
                }
                histRs.close();
                histPs.close();
                if (hasHistory) {
                    modalHistoryHtml =
                        "<table class=\"koi-history-table\">" +
                        "<thead><tr><th>Date &amp; Time</th><th>From Pond</th><th>To Pond</th></tr></thead>" +
                        "<tbody>" + histRows + "</tbody></table>";
                }
            }
            modalRs.close();
            modalPs.close();
        } catch (Exception e) {
            // modal load error is non-fatal
        } finally {
            if (modalCon != null) try { modalCon.close(); } catch (SQLException e) {}
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Koi Inventory Management - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/koi-inventory.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Show dropdown on hover — replaces the JavaScript toggleKoiMenu function */
        .koi-dot-menu:hover .koi-dropdown-menu {
            display: block;
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

    <main class="content-wrapper">
        <div class="container">
            <header class="inventory-header">
                <h2>Koi Inventory</h2>
                <a href="koiProfile.jsp" class="add-task-btn" style="text-decoration: none; color: white;">
                    <i class="fa fa-plus"></i> Create New Koi Profile
                </a>
            </header>

            <div class="koi-grid-centered">
                <%
                    java.sql.Connection con = null;
                    try {
                        con = MysqlCon.getConnection();
                        Statement stmt = con.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM koi ORDER BY created_at DESC");

                        boolean hasKoi = false;
                        while (rs.next()) {
                            hasKoi = true;
                            int id = rs.getInt("id");
                            String name    = rs.getString("name");
                            String variety = rs.getString("variety");
                            String breeder = rs.getString("breeder");
                            String sex     = rs.getString("sex");
                            int age        = rs.getInt("age");       boolean ageNull  = rs.wasNull();
                            double size    = rs.getDouble("size_cm"); boolean sizeNull = rs.wasNull();
                            int pondId     = rs.getInt("pond_id");    boolean pondNull = rs.wasNull();
                            String status  = rs.getString("status");
                %>
                    <%-- Clicking a card navigates to koi.jsp?selectedId=id, which Java uses to open the modal --%>
                    <a href="koi.jsp?selectedId=<%= id %>" style="text-decoration: none; color: inherit;">
                    <div class="koi-card-horizontal" style="cursor:pointer;">
                        <div class="koi-dot-menu" onclick="event.preventDefault(); event.stopPropagation();">
                            <button class="dot-btn">&#8942;</button>
                            <div class="koi-dropdown-menu">
                                <form action="deleteKoi" method="POST" onsubmit="return confirm('Are you sure you want to delete this koi?');">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="dropdown-item delete-item">Delete</button>
                                </form>
                            </div>
                        </div>
                        <div class="koi-card-body">
                            <div class="koi-card-name">
                                <h3><%= escapeHtml(name) %></h3>
                            </div>
                            <div class="koi-card-stats">
                                <span><strong>Pond:</strong> <%= pondNull ? "None" : pondId %></span>
                                <span>
                                    <strong>Status:</strong>
                                    <span class="koi-status-text status-<%= status != null ? status : "healthy" %>"><%= orNA(status) %></span>
                                </span>
                                <span><strong>Size:</strong> <%= sizeNull ? "N/A" : String.format("%.2f", size) + " cm" %></span>
                            </div>
                            <div class="koi-health-bar-wrapper">
                                <div class="koi-health-bar health-<%= status != null ? status : "healthy" %>"></div>
                            </div>
                            <div class="koi-card-actions">
                                <a href="koiProfile.jsp?id=<%= id %>" class="action-btn" style="text-decoration: none;" onclick="event.stopPropagation();">Update Information</a>
                            </div>
                        </div>
                    </div>
                    </a>
                <%
                        }

                        if (!hasKoi) {
                %>
                    <div class="empty-state" style="text-align: center; padding: 50px; color: #666;">
                        <p>No koi profiles found. Click "Create New Koi Profile" to get started!</p>
                    </div>
                <%
                        }
                        rs.close();
                        stmt.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error loading inventory: " + e.getMessage() + "</p>");
                    } finally {
                        if (con != null) try { con.close(); } catch (SQLException e) {}
                    }
                %>
            </div>
        </div>
    </main>

    <div id="koiModal" class="koi-modal-overlay" style="display: <%= showModal ? "flex" : "none" %>;">
        <div class="koi-modal-content">
            <a href="koi.jsp" class="koi-modal-close" style="text-decoration: none;">&times;</a>
            <h2><%= escapeHtml(modalName) %></h2>
            <div class="koi-modal-details">
                <p><strong>Variety:</strong> <%= escapeHtml(modalVariety) %></p>
                <p><strong>Breeder:</strong> <%= escapeHtml(modalBreeder) %></p>
                <p><strong>Sex:</strong>     <%= escapeHtml(modalSex) %></p>
                <p><strong>Age:</strong>     <%= modalAge %></p>
                <p><strong>Size:</strong>    <%= modalSize %></p>
                <p><strong>Pond ID:</strong> <%= modalPond %></p>
                <p><strong>Status:</strong>  <%= modalStatus %></p>
                <% if (!modalDeceased.isEmpty()) { %>
                    <p><strong>Date of Death:</strong> <%= modalDeceased %></p>
                <% } %>
                <% if (!modalNotes.isEmpty()) { %>
                    <p><strong>Notes:</strong> <%= escapeHtml(modalNotes) %></p>
                <% } %>
            </div>
            <div class="koi-modal-history">
                <h3>Pond Assignment History</h3>
                <%= modalHistoryHtml %>
            </div>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>
