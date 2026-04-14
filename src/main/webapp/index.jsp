<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Koi Pond Manager - Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>

    <%-- 
        JAVA CODE PLACE HERE...
    --%>

    <nav class="navbar">
        <div class="nav-left">
            <div class="logo">LOGO HERE???</div>
        </div>

        <div class="nav-middle">
            <div class="search-container">
                <input type="text" placeholder="Search tasks, ponds, or koi...">
                <button type="submit"><i class="fa fa-search"></i></button>
            </div>
            <div class="nav-links">
                <a href="koi.jsp">Koi</a>
                <a href="ponds.jsp">Ponds</a>
                <a href="treatments.jsp">Treatments</a>
                <a href="logs.jsp">Logs</a>
            </div>
        </div>

        <div class="nav-right">
            <div class="icon-btn" title="View Alerts">
                <i class="fa fa-bell"></i>
                <span class="badge">3</span>
            </div>
            <div class="icon-btn profile-dropdown">
                <i class="fa fa-user-circle"></i>
                <div class="dropdown-content">
                    <a href="profile.jsp">Update Profile</a>
                    <hr>
                    <a href="logout.jsp" class="logout">Logout</a>
                </div>
            </div>
        </div>
    </nav>

    <main class="content-wrapper">
        <section class="welcome-section centered">
            <h1>Welcome back, <span class="user-name">Yuujiiii</span>!</h1>
            <p>Managing your organization's ponds and koi inventory.</p>
        </section>

        <section class="task-section">
            <div class="section-header">
                <h2>Priority Tasks</h2>
                <a href="maintenance.jsp" class="add-task-btn" style="text-decoration: none;">
            		<i class="fa fa-plus"></i> Maintenance
        		</a>
            </div>
            
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>Task Name</th>
                            <th>Pond</th>
                            <th>Deadline</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%-- 
                            JAVA LOOP PLACEHOLDER: 
                            You will use a 'while' or 'for' loop here to iterate through 
                            ResultSet rows from your MaintenanceTask table[cite: 285].
                        --%>
                        
                        <tr class="task-row urgent">
                            <td>UV Bulb Inspection</td>
                            <td>Pond Kohaku</td>
                            <td>2026-03-24</td>
                            <td><span class="status-flag">Overdue</span></td>
                        </tr>
                        
                        <tr class="task-row">
                            <td>Water Quality Test</td>
                            <td>Pond Sakura</td>
                            <td>2026-03-25</td>
                            <td>Pending</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <footer class="fixed-footer">
        <div class="footer-left">
            <h3>Koi Pond Manager</h3>
            <p>Designed for dealers and hobbyists to prevent fish death and financial loss.</p>
        </div>
        <div class="footer-right">
            <h3>Support & Contact</h3>
            <p><strong>Organization:</strong> Blue Ridge Koi Farm</p>
            <p>Contact: yuji.nishi@blueridgekoifarm.com</p>
        </div>
    </footer>

</body>
</html>