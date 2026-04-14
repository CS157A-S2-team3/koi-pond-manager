<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
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
        <%-- Summary Cards --%>
        <div class="summary-cards">
            <div class="card">
                <div class="card-label">Total Ponds</div>
                <div class="card-value">6</div>
                <div class="card-sub">2 need attention</div>
            </div>
            <div class="card">
                <div class="card-label">Koi Inventory</div>
                <div class="card-value">134</div>
                <div class="card-sub">12 added this month</div>
            </div>
            <div class="card">
                <div class="card-label">Water Quality</div>
                <div class="card-value">82%</div>
                <div class="card-sub">Avg. across all ponds</div>
            </div>
            <div class="card">
                <div class="card-label">Open Tasks</div>
                <div class="card-value">5</div>
                <div class="card-sub">1 overdue</div>
            </div>
        </div>

        <%-- Pond Overview --%>
        <div class="section">
            <h2>Pond Overview</h2>
            <table>
                <thead>
                    <tr>
                        <th>Pond Name</th>
                        <th>Capacity</th>
                        <th>Koi Count</th>
                        <th>Water Quality</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%-- Replace with dynamic data from database --%>
                    <tr>
                        <td>Kohaku</td>
                        <td>5,000 gal</td>
                        <td>28</td>
                        <td>94%</td>
                        <td><span class="badge badge-good">Good</span></td>
                    </tr>
                    <tr>
                        <td>Sakura</td>
                        <td>3,200 gal</td>
                        <td>19</td>
                        <td>76%</td>
                        <td><span class="badge badge-warn">Fair</span></td>
                    </tr>
                    <tr>
                        <td>Taisho</td>
                        <td>4,500 gal</td>
                        <td>34</td>
                        <td>45%</td>
                        <td><span class="badge badge-danger">Poor</span></td>
                    </tr>
                    <tr>
                        <td>Showa</td>
                        <td>6,000 gal</td>
                        <td>22</td>
                        <td>88%</td>
                        <td><span class="badge badge-good">Good</span></td>
                    </tr>
                </tbody>
            </table>
        </div>

        <%-- Two column: Recent Activity + Water Quality --%>
        <div class="two-col">
            <div class="section">
                <h2>Recent Activity</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Event</th>
                            <th>Pond</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Apr 13</td>
                            <td>Water test completed</td>
                            <td>Kohaku</td>
                        </tr>
                        <tr>
                            <td>Apr 12</td>
                            <td>3 koi transferred</td>
                            <td>Sakura</td>
                        </tr>
                        <tr>
                            <td>Apr 11</td>
                            <td>Filter cleaned</td>
                            <td>Taisho</td>
                        </tr>
                        <tr>
                            <td>Apr 10</td>
                            <td>Salt treatment applied</td>
                            <td>Showa</td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <div class="section">
                <h2>Water Quality Stats</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Parameter</th>
                            <th>Avg Value</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>pH Level</td>
                            <td>7.4</td>
                            <td><span class="badge badge-good">Normal</span></td>
                        </tr>
                        <tr>
                            <td>Ammonia</td>
                            <td>0.12 ppm</td>
                            <td><span class="badge badge-good">Safe</span></td>
                        </tr>
                        <tr>
                            <td>Nitrite</td>
                            <td>0.8 ppm</td>
                            <td><span class="badge badge-warn">Elevated</span></td>
                        </tr>
                        <tr>
                            <td>Temperature</td>
                            <td>72&#176;F</td>
                            <td><span class="badge badge-good">Optimal</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>
