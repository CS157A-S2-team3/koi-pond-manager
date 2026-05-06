<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat, com.koi.MysqlCon" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    int orgId = (Integer) session.getAttribute("orgId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pond Health - Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<%@ include file="header.jsp" %>

<main>
    <div class="page-header">
        <h2>Pond Health</h2>
    </div>

    <%
        // Issue thresholds (rules of thumb for koi keeping)
        final double AMMONIA_MAX = 0.25;
        final double NITRITE_MAX = 0.25;
        final double PH_MIN = 6.5;
        final double PH_MAX = 8.5;
        final int    TEST_STALE_DAYS = 7;

        java.sql.Connection con = null;
        String error = null;

        // Aggregated stats
        int needAttention = 0;
        int activeTreatmentsTotal = 0;
        int overdueTests = 0;
        int unhealthyFishTotal = 0;

        // Row data: each pond + the issue tags we've detected for it
        List<Map<String, Object>> rows = new ArrayList<>();

        try {
            con = MysqlCon.getConnection();
            PreparedStatement ps = con.prepareStatement(
                "SELECT pond_id, code, name, volume, is_quarantine, location_name, "
              + "       last_test_at, last_ph, last_ammonia, last_nitrite, last_temperature, "
              + "       days_since_test, koi_count, unhealthy_koi_count, active_treatment_count "
              + "FROM pond_health WHERE organization_id = ? "
              + "ORDER BY location_order, code");
            ps.setInt(1, orgId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("code", rs.getString("code"));
                row.put("name", rs.getString("name"));
                row.put("locationName", rs.getString("location_name"));
                row.put("isQuarantine", rs.getBoolean("is_quarantine"));

                Timestamp lastTestAt = rs.getTimestamp("last_test_at");
                row.put("lastTestAt", lastTestAt);

                double lastPh         = rs.getDouble("last_ph");        boolean phNull       = rs.wasNull();
                double lastAmmonia    = rs.getDouble("last_ammonia");   boolean ammoniaNull  = rs.wasNull();
                double lastNitrite    = rs.getDouble("last_nitrite");   boolean nitriteNull  = rs.wasNull();
                int    daysSinceTest  = rs.getInt("days_since_test");   boolean testNeverRun = rs.wasNull();
                int    koiCount       = rs.getInt("koi_count");
                int    unhealthy      = rs.getInt("unhealthy_koi_count");
                int    activeTx       = rs.getInt("active_treatment_count");

                row.put("lastPh",       phNull       ? null : lastPh);
                row.put("lastAmmonia",  ammoniaNull  ? null : lastAmmonia);
                row.put("lastNitrite",  nitriteNull  ? null : lastNitrite);
                row.put("koiCount",     koiCount);
                row.put("unhealthy",    unhealthy);
                row.put("activeTx",     activeTx);

                // Detect issues
                List<String[]> issues = new ArrayList<>(); // [label, severity]
                boolean hasIssue = false;

                boolean stale = (testNeverRun || daysSinceTest > TEST_STALE_DAYS) && koiCount > 0;
                if (stale) {
                    issues.add(new String[]{
                        testNeverRun ? "No water test on record" : "Test " + daysSinceTest + "d old",
                        "warn"});
                    overdueTests++;
                    hasIssue = true;
                }
                if (!ammoniaNull && lastAmmonia > AMMONIA_MAX) {
                    issues.add(new String[]{"Ammonia " + lastAmmonia, "danger"});
                    hasIssue = true;
                }
                if (!nitriteNull && lastNitrite > NITRITE_MAX) {
                    issues.add(new String[]{"Nitrite " + lastNitrite, "danger"});
                    hasIssue = true;
                }
                if (!phNull && (lastPh < PH_MIN || lastPh > PH_MAX)) {
                    issues.add(new String[]{"pH " + lastPh, "danger"});
                    hasIssue = true;
                }
                if (unhealthy > 0) {
                    issues.add(new String[]{unhealthy + " unhealthy koi", "danger"});
                    unhealthyFishTotal += unhealthy;
                    hasIssue = true;
                }
                if (activeTx > 0) {
                    // Informational only — does not count as "needs attention"
                    issues.add(new String[]{activeTx + " active treatment" + (activeTx == 1 ? "" : "s"), "good"});
                    activeTreatmentsTotal += activeTx;
                }

                if (hasIssue) needAttention++;
                row.put("issues", issues);
                rows.add(row);
            }
            rs.close();
            ps.close();
        } catch (Exception e) {
            error = e.getMessage();
        } finally {
            if (con != null) try { con.close(); } catch (SQLException ignored) {}
        }
    %>

    <% if (error != null) { %>
        <div class="alert alert-danger">Error loading pond health: <%= error %></div>
    <% } %>

    <div class="summary-cards">
        <div class="card">
            <div class="card-label">Need Attention</div>
            <div class="card-value"><%= needAttention %></div>
            <div class="card-sub">of <%= rows.size() %> ponds</div>
        </div>
        <div class="card">
            <div class="card-label">Overdue Tests</div>
            <div class="card-value"><%= overdueTests %></div>
            <div class="card-sub">stocked ponds untested &gt; <%= TEST_STALE_DAYS %>d</div>
        </div>
        <div class="card">
            <div class="card-label">Unhealthy Fish</div>
            <div class="card-value"><%= unhealthyFishTotal %></div>
            <div class="card-sub">across all ponds</div>
        </div>
        <div class="card">
            <div class="card-label">Active Treatments</div>
            <div class="card-value"><%= activeTreatmentsTotal %></div>
            <div class="card-sub">currently dosing</div>
        </div>
    </div>

    <div class="section">
        <h2>Per-pond Status</h2>
        <% if (rows.isEmpty()) { %>
            <p class="muted-text">No ponds yet. Add some on the <a href="ponds.jsp">Ponds page</a>.</p>
        <% } else { %>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Pond</th>
                    <th>Location</th>
                    <th>Koi</th>
                    <th>Last Test</th>
                    <th>pH</th>
                    <th>Ammonia</th>
                    <th>Nitrite</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    SimpleDateFormat dayFmt = new SimpleDateFormat("MMM d");
                    for (Map<String, Object> row : rows) {
                        Timestamp lastTestAt = (Timestamp) row.get("lastTestAt");
                        Double lastPh = (Double) row.get("lastPh");
                        Double lastAmmonia = (Double) row.get("lastAmmonia");
                        Double lastNitrite = (Double) row.get("lastNitrite");
                        @SuppressWarnings("unchecked")
                        List<String[]> issues = (List<String[]>) row.get("issues");
                %>
                <tr>
                    <td><strong><%= row.get("code") %></strong>
                        <% if ((Boolean) row.get("isQuarantine")) { %>
                            <span class="badge badge-warn">Q</span>
                        <% } %>
                    </td>
                    <td><%= row.get("locationName") %></td>
                    <td><%= row.get("koiCount") %></td>
                    <td><%= lastTestAt != null ? dayFmt.format(lastTestAt) : "—" %></td>
                    <td><%= lastPh != null ? lastPh : "—" %></td>
                    <td><%= lastAmmonia != null ? lastAmmonia : "—" %></td>
                    <td><%= lastNitrite != null ? lastNitrite : "—" %></td>
                    <td>
                        <% if (issues.isEmpty()) { %>
                            <span class="badge badge-good">OK</span>
                        <% } else {
                               for (String[] issue : issues) { %>
                            <span class="badge badge-<%= issue[1] %>"><%= issue[0] %></span>
                        <%     }
                           } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>

        <p class="card-sub" style="margin-top: 1rem;">
            Backed by the <code>pond_health</code> SQL view — joins ponds, the latest water test (window function),
            koi counts, and active treatments (where <code>created_at + duration days &gt;= today</code>).
        </p>
    </div>
</main>

<%@ include file="footer.jsp" %>

</body>
</html>
