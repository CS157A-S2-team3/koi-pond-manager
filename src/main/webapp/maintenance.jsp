<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    <nav class="navbar">
        <div class="nav-left">
            <a href="index.jsp" class="logo" style="text-decoration: none; color: white;">LOGO HERE???</a>
        </div>
        <div class="nav-middle">
            <div class="nav-links">
                <a href="koi.jsp">Koi</a>
                <a href="ponds.jsp">Ponds</a>
                <a href="treatments.jsp">Treatments</a>
                <a href="logs.jsp">Logs</a>
            </div>
        </div>
    </nav>

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
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="task-row urgent">
                            <td>UV Bulb Inspection</td>
                            <td>Monthly</td>
                            <td>2026-03-24</td>
                            <td><span class="status-flag overdue">Overdue</span></td>
                            <td><button class="action-btn">Complete</button></td>
                        </tr>
                        <tr class="task-row">
                            <td>Water Change</td>
                            <td>Weekly</td>
                            <td>2026-04-15</td>
                            <td><span class="status-flag pending">Pending</span></td>
                            <td><button class="action-btn">Complete</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="maintenance-grid">
            <div class="info-card">
                <i class="fa fa-calculator"></i>
                <h4>Feeding Calculation</h4>
                <p>Based on breed, size, and age.</p>
            </div>
            <div class="info-card">
                <i class="fa fa-flask"></i>
                <h4>Dosing Calculator</h4>
                <p>Based on pond volume.</p>
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
        function openModal() { document.getElementById('maintenanceModal').style.display = 'block'; }
        function closeModal() { document.getElementById('maintenanceModal').style.display = 'none'; }
    </script>
</body>
</html>