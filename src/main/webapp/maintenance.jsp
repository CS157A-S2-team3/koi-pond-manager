<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon, java.time.LocalDate" %>
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
    <title>Maintenance & Feeding - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/maintenance-style.css">
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

    <main class="content-wrapper container">
        <header class="section-header-top">
            <h2>Maintenance & Feeding</h2>
            <button class="add-task-btn" onclick="openModal()">
                <i class="fa fa-plus"></i> Add Maintenance Schedule
            </button>
        </header>

        <section class="maintenance-box">
            <h3>Active Tasks</h3>
            <p class="subtitle">Tasks generated from recurring schedules.</p>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Task Name</th>
                            <th>Frequency</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Action</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        Connection con = null;
                        try {
                            con = MysqlCon.getConnection();
                            String sql = "SELECT t.schedule_id, t.due_at, t.status, t.notes, s.freq " +
                                         "FROM MaintenanceTask t " +
                                         "JOIN MaintenanceSchedule s ON t.schedule_id = s.id " +
                                         "WHERE s.user_id = ? AND t.status != 'Completed' " +
                                         "ORDER BY t.due_at ASC";
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setInt(1, (int) session.getAttribute("userId"));
                            ResultSet rs = ps.executeQuery();
                            
                            LocalDate today = LocalDate.now();
                            boolean hasRows = false;
                            
                            while (rs.next()) {
                                hasRows = true;
                                String taskNotes = rs.getString("notes");
                                String freq = rs.getString("freq");
                                Date dueDate = rs.getDate("due_at");
                                String status = rs.getString("status");
                                int scheduleId = rs.getInt("schedule_id");
                                
                                LocalDate due = dueDate.toLocalDate();
                                boolean isOverdue = due.isBefore(today) && !"Completed".equals(status);
                                String displayStatus = isOverdue ? "Overdue" : status;
                                String statusClass = isOverdue ? "overdue" : "pending";
                                String rowClass = isOverdue ? "task-row urgent" : "task-row";
                    %>
                        <tr class="<%= rowClass %>">
                            <td><%= taskNotes %></td>
                            <td><%= freq %></td>
                            <td><%= dueDate %></td>
                            <td><span class="status-flag <%= statusClass %>"><%= displayStatus %></span></td>
                            <td>
                                <form action="completeTask" method="POST" style="display:inline;">
                                    <input type="hidden" name="schedule_id" value="<%= scheduleId %>">
                                    <input type="hidden" name="due_at" value="<%= dueDate %>">
                                    <button type="submit" class="action-btn">Complete</button>
                                </form>
                            </td>
                            <td class="menu-cell">
                                <div class="three-dot-menu">
                                    <button class="dot-btn" onclick="toggleMenu(this)">&#8942;</button>
                                    <div class="dropdown-menu">
                                        <form action="deactivateSchedule" method="POST">
                                            <input type="hidden" name="schedule_id" value="<%= scheduleId %>">
                                            <button type="submit" class="dropdown-item deactivate-item">Deactivate</button>
                                        </form>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    <%
                            }
                            if (!hasRows) {
                    %>
                        <tr>
                            <td colspan="5" style="text-align:center; color:#6c757d; padding:2rem;">
                                No active tasks. Create a maintenance schedule to get started.
                            </td>
                        </tr>
                    <%
                            }
                            rs.close();
                            ps.close();
                        } catch (Exception e) {
                    %>
                        <tr>
                            <td colspan="5" style="color:#dc3545;">Error loading tasks: <%= e.getMessage() %></td>
                        </tr>
                    <%
                        } finally {
                            if (con != null) try { con.close(); } catch (Exception e) {}
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <div id="maintenanceModal" class="modal">
        <div class="modal-content white-form-box">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Create Recurring Schedule</h2>
            <form action="saveSchedule" method="POST" class="maintenance-form">
                <div class="form-group">
                    <label>Task Name</label>
                    <input type="text" name="notes" placeholder="e.g., Filter Rinse" required>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Frequency</label>
                        <select name="freq">
                            <option value="Daily">Daily</option>
                            <option value="Weekly">Weekly</option>
                            <option value="Biweekly">Biweekly</option>
                            <option value="Monthly">Monthly</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Start Date</label>
                        <input type="date" name="due_at" required>
                    </div>
                </div>
                <div class="form-actions">
                    <button type="submit">Save Schedule</button>
                    <button type="button" class="cancel-link" onclick="closeModal()">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() { document.getElementById('maintenanceModal').style.display = 'flex'; }
        function closeModal() { document.getElementById('maintenanceModal').style.display = 'none'; }
        
        function toggleMenu(btn) {
            // Close all other open menus
            document.querySelectorAll('.dropdown-menu.show').forEach(function(menu) {
                if (menu !== btn.nextElementSibling) menu.classList.remove('show');
            });
            btn.nextElementSibling.classList.toggle('show');
        }
        
        // Close menus when clicking outside
        document.addEventListener('click', function(e) {
            if (!e.target.classList.contains('dot-btn')) {
                document.querySelectorAll('.dropdown-menu.show').forEach(function(menu) {
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
