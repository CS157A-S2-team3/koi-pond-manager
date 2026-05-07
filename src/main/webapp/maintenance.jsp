<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.koi.MysqlCon, java.time.LocalDate" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int orgId = (Integer) session.getAttribute("orgId");
    int userId = (Integer) session.getAttribute("userId");
    String error = null;
    String success = null;

    String action = request.getParameter("action");
    boolean showModal = "addSchedule".equals(action);

    java.sql.Connection con = null;
    try {
        con = MysqlCon.getConnection();

        if ("saveSchedule".equals(action)) {
            String notes = request.getParameter("notes");
            String freq = request.getParameter("freq");
            String dueAt = request.getParameter("due_at");

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO MaintenanceSchedule (organization_id, notes, freq, user_id) VALUES (?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, orgId);
            ps.setString(2, notes);
            ps.setString(3, freq);
            ps.setInt(4, userId);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int scheduleId = keys.getInt(1);

                LocalDate startDate = LocalDate.parse(dueAt);
                LocalDate firstDue;
                switch (freq) {
                    case "Daily":    firstDue = startDate.plusDays(1); break;
                    case "Weekly":   firstDue = startDate.plusWeeks(1); break;
                    case "Biweekly": firstDue = startDate.plusWeeks(2); break;
                    case "Monthly":  firstDue = startDate.plusMonths(1); break;
                    default:         firstDue = startDate.plusWeeks(1);
                }

                PreparedStatement taskPs = con.prepareStatement(
                    "INSERT INTO MaintenanceTask (schedule_id, due_at, status, notes) VALUES (?, ?, 'Pending', ?)");
                taskPs.setInt(1, scheduleId);
                taskPs.setDate(2, Date.valueOf(firstDue));
                taskPs.setString(3, notes);
                taskPs.executeUpdate();
                taskPs.close();
            }
            keys.close();
            ps.close();
            success = "Schedule created.";

        } else if ("completeTask".equals(action)) {
            int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));
            String dueAt = request.getParameter("due_at");
            LocalDate currentDue = LocalDate.parse(dueAt);

            PreparedStatement chk = con.prepareStatement(
                "SELECT s.freq, s.notes FROM MaintenanceSchedule s WHERE s.id = ? AND s.organization_id = ?");
                chk.setInt(1, scheduleId);
                chk.setInt(2, orgId);
                ResultSet chkRs = chk.executeQuery();
                if (!chkRs.next()) {
                    error = "Schedule not found.";
                } else {
                    String freq = chkRs.getString("freq");
                    String taskNotes = chkRs.getString("notes");
                    chkRs.close();
                    chk.close();

                    PreparedStatement up = con.prepareStatement(
                        "UPDATE MaintenanceTask SET status = 'Completed', completed_at = NOW(), completed_by_user_id = ? "
                      + "WHERE schedule_id = ? AND due_at = ?");
                    up.setInt(1, userId);
                    up.setInt(2, scheduleId);
                    up.setDate(3, Date.valueOf(dueAt));
                    up.executeUpdate();
                    up.close();

                    LocalDate baseDate = currentDue.isBefore(LocalDate.now()) ? LocalDate.now() : currentDue;
                    LocalDate nextDue;
                    switch (freq) {
                        case "Daily":    nextDue = baseDate.plusDays(1); break;
                        case "Weekly":   nextDue = baseDate.plusWeeks(1); break;
                        case "Biweekly": nextDue = baseDate.plusWeeks(2); break;
                        case "Monthly":  nextDue = baseDate.plusMonths(1); break;
                        default:         nextDue = baseDate.plusWeeks(1);
                    }

                    PreparedStatement ins = con.prepareStatement(
                        "INSERT IGNORE INTO MaintenanceTask (schedule_id, due_at, status, notes) VALUES (?, ?, 'Pending', ?)");
                    ins.setInt(1, scheduleId);
                    ins.setDate(2, Date.valueOf(nextDue));
                    ins.setString(3, taskNotes);
                    ins.executeUpdate();
                    ins.close();
                    success = "Task completed.";
                }

        } else if ("deactivateSchedule".equals(action)) {
            int scheduleId = Integer.parseInt(request.getParameter("schedule_id"));
            PreparedStatement up = con.prepareStatement(
                "UPDATE MaintenanceSchedule SET status = 'Inactive', completed_at = NOW() "
              + "WHERE id = ? AND organization_id = ?");
            up.setInt(1, scheduleId);
            up.setInt(2, orgId);
            int rows = up.executeUpdate();
            up.close();
            if (rows == 0) {
                error = "Schedule not found.";
            } else {
                PreparedStatement del = con.prepareStatement(
                    "DELETE FROM MaintenanceTask WHERE schedule_id = ? AND status = 'Pending'");
                del.setInt(1, scheduleId);
                del.executeUpdate();
                del.close();
                success = "Schedule deactivated.";
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
    <title>Maintenance & Feeding - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/maintenance-style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .three-dot-menu:hover .dropdown-menu {
            display: block;
        }
        .status-flag.completed-flash {
            color: #2e7d32;
            font-weight: bold;
        }
        .action-btn:disabled {
            background-color: #ccc;
            color: #666;
            cursor: not-allowed;
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>

    <main class="content-wrapper container">
        <header class="section-header-top">
            <h2>Maintenance & Feeding</h2>
            <a href="maintenance.jsp?action=addSchedule" class="add-task-btn" style="text-decoration: none; color: white;">
                <i class="fa fa-plus"></i> Add Maintenance Schedule
            </a>
        </header>

        <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %></div>
        <% } %>
        <% if (success != null) { %>
            <div class="alert alert-success"><%= success %></div>
        <% } %>

        <section class="maintenance-box">
            <h3>Overdue Water Tests</h3>
            <p class="subtitle">Virtual tasks: stocked ponds whose last water test is missing or more than 7 days old. Resolves automatically once you log a test for the pond.</p>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Pond</th>
                            <th>Location</th>
                            <th>Koi</th>
                            <th>Last Test</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        try {
                            if (con == null || con.isClosed()) con = MysqlCon.getConnection();
                            // pond_health is a view defined in schema.sql that joins ponds, the
                            // latest water test per pond, and counts of koi / active treatments.
                            //   koi_count > 0          -> empty ponds aren't "overdue", just unused
                            //   last_test_at IS NULL   -> covers the never-tested case
                            //   days_since_test > 7    -> our staleness threshold (matches health.jsp)
                            // ORDER BY last_test_at ascending puts NULLs (never-tested) first,
                            // then oldest tests, then more recent ones — MySQL's default null
                            // ordering happens to give us "most urgent first" for free.
                            PreparedStatement overduePs = con.prepareStatement(
                                "SELECT pond_id, code, location_name, koi_count, last_test_at, days_since_test "
                              + "FROM pond_health "
                              + "WHERE organization_id = ? "
                              + "  AND koi_count > 0 "
                              + "  AND (last_test_at IS NULL OR days_since_test > 7) "
                              + "ORDER BY last_test_at, code");
                            overduePs.setInt(1, orgId);
                            ResultSet overdueRs = overduePs.executeQuery();
                            boolean hasOverdue = false;
                            while (overdueRs.next()) {
                                hasOverdue = true;
                                int pondId = overdueRs.getInt("pond_id");
                                String code = overdueRs.getString("code");
                                String locationName = overdueRs.getString("location_name");
                                int koiCount = overdueRs.getInt("koi_count");
                                java.sql.Timestamp lastAt = overdueRs.getTimestamp("last_test_at");
                                int daysSince = overdueRs.getInt("days_since_test");
                                boolean neverTested = overdueRs.wasNull();
                                String lastDisplay = neverTested ? "Never" : new java.text.SimpleDateFormat("MMM d").format(lastAt);
                                String statusLabel = neverTested ? "Never tested" : daysSince + " days overdue";
                    %>
                        <tr class="task-row urgent">
                            <td><strong><%= code %></strong></td>
                            <td><%= locationName %></td>
                            <td><%= koiCount %></td>
                            <td><%= lastDisplay %></td>
                            <td><span class="status-flag overdue"><%= statusLabel %></span></td>
                            <td><a href="waterTest.jsp?pondId=<%= pondId %>" class="action-btn" style="text-decoration:none;">Log Test</a></td>
                        </tr>
                    <%
                            }
                            overdueRs.close();
                            overduePs.close();
                            if (!hasOverdue) {
                    %>
                        <tr>
                            <td colspan="6" style="text-align:center; color:#6c757d; padding:1.5rem;">
                                No overdue water tests — every stocked pond is current.
                            </td>
                        </tr>
                    <%
                            }
                        } catch (Exception e) {
                    %>
                        <tr>
                            <td colspan="6" style="color:#dc3545;">Error loading overdue tests: <%= e.getMessage() %></td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </section>

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
                        try {
                            if (con == null || con.isClosed()) con = MysqlCon.getConnection();
                            String sql = "SELECT t.schedule_id, t.due_at, t.status, t.notes, s.freq " +
                                         "FROM MaintenanceTask t " +
                                         "JOIN MaintenanceSchedule s ON t.schedule_id = s.id " +
                                         "WHERE s.organization_id = ? AND t.status <> 'Completed' " +
                                         "ORDER BY t.due_at ASC";
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setInt(1, orgId);
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
                                <form action="maintenance.jsp" method="POST" style="display:inline;" class="complete-form">
                                    <input type="hidden" name="action" value="completeTask">
                                    <input type="hidden" name="schedule_id" value="<%= scheduleId %>">
                                    <input type="hidden" name="due_at" value="<%= dueDate %>">
                                    <button type="submit" class="action-btn">Complete</button>
                                </form>
                            </td>
                            <td class="menu-cell">
                                <div class="three-dot-menu">
                                    <button class="dot-btn">&#8942;</button>
                                    <div class="dropdown-menu">
                                        <form action="maintenance.jsp" method="POST">
                                            <input type="hidden" name="action" value="deactivateSchedule">
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

    <div id="maintenanceModal" class="modal" style="display: <%= showModal ? "flex" : "none" %>;">
        <div class="modal-content white-form-box">
            <a href="maintenance.jsp" class="close" style="text-decoration: none;">&times;</a>
            <h2>Create Recurring Schedule</h2>
            <form action="maintenance.jsp" method="POST" class="maintenance-form">
                <input type="hidden" name="action" value="saveSchedule">
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
                    <%-- Cancel link: navigates back to maintenance.jsp, closing the modal --%>
                    <a href="maintenance.jsp" class="cancel-link" style="text-decoration: none; padding: 12px 35px; font-size: 1.15rem; cursor: pointer;">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <%@ include file="footer.jsp" %>

    <script>
        document.querySelectorAll('form.complete-form').forEach(function(form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();

                var row = form.closest('tr');
                var statusCell = row.querySelector('.status-flag');
                var completeBtn = form.querySelector('button[type="submit"]');

                completeBtn.disabled = true;

                var data = new URLSearchParams(new FormData(form));

                fetch('maintenance.jsp', { 
                    method: 'POST', 
                    body: data, 
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                })
                    .then(function(response) {
                        if (!response.ok) throw new Error('Server error: ' + response.status);

                        statusCell.className = 'status-flag completed-flash';
                        statusCell.textContent = 'Completed';
                        row.className = 'task-row';

                        setTimeout(function() {
                            window.location.href = 'maintenance.jsp';
                        }, 5000);
                    })
                    .catch(function(err) {
                        completeBtn.disabled = false;
                        alert('Could not complete task: ' + err.message);
                    });
            });
        });
    </script>
</body>
</html>
