<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Koi Inventory Management - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/koi-inventory.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
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
            	<a href="koiProfile.jsp" class="add-task-btn" style="text-decoration: none;">
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
                            String name = rs.getString("name");
                            String variety = rs.getString("variety");
                            String breeder = rs.getString("breeder");
                            String sex = rs.getString("sex");
                            int age = rs.getInt("age");
                            boolean ageNull = rs.wasNull();
                            double size = rs.getDouble("size_cm");
                            boolean sizeNull = rs.wasNull();
                            int pondId = rs.getInt("pond_id");
                            boolean pondNull = rs.wasNull();
                            String status = rs.getString("status");
                            java.sql.Timestamp updatedAt = rs.getTimestamp("updated_at");
                            SimpleDateFormat dtf = new SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a");
                            String deceasedDisplay = ("deceased".equals(status) && updatedAt != null) ? dtf.format(updatedAt) : "";

                            // Build pond history JSON for this koi
                            StringBuilder histJson = new StringBuilder("[");
                            try (PreparedStatement histPs = con.prepareStatement(
                                    "SELECT kph.moved_at, " +
                                    "COALESCE(pf.name, 'None') AS from_name, " +
                                    "COALESCE(pt.name, 'None') AS to_name " +
                                    "FROM koi_pond_history kph " +
                                    "LEFT JOIN ponds pf ON kph.from_pond_id = pf.id " +
                                    "LEFT JOIN ponds pt ON kph.to_pond_id  = pt.id " +
                                    "WHERE kph.koi_id = ? ORDER BY kph.moved_at ASC")) {
                                histPs.setInt(1, id);
                                ResultSet histRs = histPs.executeQuery();
                                SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                                boolean firstHist = true;
                                while (histRs.next()) {
                                    if (!firstHist) histJson.append(",");
                                    String fromName = histRs.getString("from_name").replace("'", "\\'").replace("\"", "&quot;");
                                    String toName   = histRs.getString("to_name").replace("'", "\\'").replace("\"", "&quot;");
                                    String movedAt  = sdf.format(histRs.getTimestamp("moved_at"));
                                    histJson.append("{\"from\":\"").append(fromName)
                                            .append("\",\"to\":\"").append(toName)
                                            .append("\",\"date\":\"").append(movedAt).append("\"}");
                                    firstHist = false;
                                }
                                histRs.close();
                            }
                            histJson.append("]");
                            String historyData = histJson.toString();
                %>
                    <div class="koi-card-horizontal" 
                        data-history='<%= historyData %>'
                        onclick="openKoiModal(this, '<%= name.replace("'", "\\'") %>', '<%= variety != null ? variety.replace("'", "\\'") : "N/A" %>', '<%= breeder != null ? breeder.replace("'", "\\'") : "N/A" %>', '<%= sex != null ? sex : "N/A" %>', '<%= ageNull ? "N/A" : age %>', '<%= sizeNull ? "N/A" : String.format("%.2f", size) + " cm" %>', '<%= pondNull ? "None" : pondId %>', '<%= status != null ? status : "N/A" %>', '<%= deceasedDisplay.replace("'", "\\'") %>')" style="cursor:pointer;">
                        <div class="koi-dot-menu" onclick="event.stopPropagation();">
                            <button class="dot-btn" onclick="toggleKoiMenu(event, this)">&#8942;</button>
                            <div class="koi-dropdown-menu">
                                <form action="deleteKoi" method="POST" onsubmit="return confirm('Are you sure you want to delete this koi?');">
                                    <input type="hidden" name="id" value="<%= id %>">
                                    <button type="submit" class="dropdown-item delete-item">Delete</button>
                                </form>
                            </div>
                        </div>
                        <div class="koi-card-body">
                            <div class="koi-card-name">
                                <h3><%= name %></h3>
                            </div>
                            <div class="koi-card-stats">
                                <span><strong>Pond:</strong> <%= pondNull ? "None" : pondId %></span>
                                <span>
                                    <strong>Status:</strong>
                                    <span class="koi-status-text status-<%= status != null ? status : "healthy" %>"><%= status != null ? status : "N/A" %></span>
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

    <!-- Koi Detail Modal -->
    <div id="koiModal" class="koi-modal-overlay" onclick="closeKoiModal(event)">
        <div class="koi-modal-content" onclick="event.stopPropagation()">
            <span class="koi-modal-close" onclick="closeKoiModal()">&times;</span>
            <h2 id="koiModalName"></h2>
            <div class="koi-modal-details">
                <p><strong>Variety:</strong> <span id="koiModalVariety"></span></p>
                <p><strong>Breeder:</strong> <span id="koiModalBreeder"></span></p>
                <p><strong>Sex:</strong> <span id="koiModalSex"></span></p>
                <p><strong>Age:</strong> <span id="koiModalAge"></span></p>
                <p><strong>Size:</strong> <span id="koiModalSize"></span></p>
                <p><strong>Pond ID:</strong> <span id="koiModalPond"></span></p>
                <p><strong>Status:</strong> <span id="koiModalStatus"></span></p>
                <p id="koiModalDeceasedRow" style="display:none;"><strong>Date of Death:</strong> <span id="koiModalDeceased"></span></p>
            </div>
            <div class="koi-modal-history">
                <h3>Pond Assignment History</h3>
                <div id="koiModalHistoryBody"></div>
            </div>
        </div>
    </div>

    <script>
        function openKoiModal(card, name, variety, breeder, sex, age, size, pond, status, deceased) {
            document.getElementById('koiModalName').textContent = name;
            document.getElementById('koiModalVariety').textContent = variety;
            document.getElementById('koiModalBreeder').textContent = breeder;
            document.getElementById('koiModalSex').textContent = sex;
            document.getElementById('koiModalAge').textContent = age;
            document.getElementById('koiModalSize').textContent = size;
            document.getElementById('koiModalPond').textContent = pond;
            document.getElementById('koiModalStatus').textContent = status;

            // Show/hide Date of Death row
            var deceasedRow = document.getElementById('koiModalDeceasedRow');
            if (status === 'deceased' && deceased) {
                document.getElementById('koiModalDeceased').textContent = deceased;
                deceasedRow.style.display = 'block';
            } else {
                deceasedRow.style.display = 'none';
            }

            // Render pond assignment history
            var historyBody = document.getElementById('koiModalHistoryBody');
            var history = [];
            try { history = JSON.parse(card.dataset.history || '[]'); } catch(e) {}

            if (history.length === 0) {
                historyBody.innerHTML = '<p class="koi-history-empty">No pond transfers recorded.</p>';
            } else {
                var rows = history.map(function(h) {
                    return '<tr><td>' + h.date + '</td><td>' + h.from + '</td><td>' + h.to + '</td></tr>';
                }).join('');
                historyBody.innerHTML =
                    '<table class="koi-history-table">' +
                    '<thead><tr><th>Date &amp; Time</th><th>From Pond</th><th>To Pond</th></tr></thead>' +
                    '<tbody>' + rows + '</tbody></table>';
            }

            document.getElementById('koiModal').style.display = 'flex';
        }
        function closeKoiModal(event) {
            if (!event || event.target === document.getElementById('koiModal')) {
                document.getElementById('koiModal').style.display = 'none';
            }
        }
        function toggleKoiMenu(e, btn) {
            e.stopPropagation();
            document.querySelectorAll('.koi-dropdown-menu.show').forEach(function(menu) {
                if (menu !== btn.nextElementSibling) menu.classList.remove('show');
            });
            btn.nextElementSibling.classList.toggle('show');
        }
        document.addEventListener('click', function(e) {
            if (!e.target.classList.contains('dot-btn')) {
                document.querySelectorAll('.koi-dropdown-menu.show').forEach(function(menu) {
                    menu.classList.remove('show');
                });
            }
        });
    </script>
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>
