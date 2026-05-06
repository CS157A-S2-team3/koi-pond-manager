<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.koi.MysqlCon, com.koi.EnvLoader, com.koi.ShopifyKoiClient" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    if (!"admin".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
    int orgId = (Integer) session.getAttribute("orgId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import Koi from Shopify - Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<%@ include file="header.jsp" %>

<main>
    <div class="page-header">
        <h2>Import Koi from Shopify</h2>
    </div>

    <%
        String shopDomain = null;
        boolean credsConfigured = false;
        try {
            shopDomain = EnvLoader.get("SHOPIFY_SHOP_DOMAIN");
            String token = EnvLoader.get("SHOPIFY_ADMIN_API_TOKEN");
            credsConfigured = shopDomain != null && !shopDomain.isEmpty()
                           && token != null && !token.isEmpty();
        } catch (Exception e) { /* fall through */ }

        // Run-time results (only populated on POST)
        boolean ranImport = "import".equals(request.getParameter("action"));
        int imported = 0, alreadyHad = 0, unknownPond = 0, errors = 0;
        List<String[]> rowReports = new ArrayList<>(); // [status, name, retailTank, detail]
        String topError = null;

        if (ranImport) {
            if (!credsConfigured) {
                topError = "Shopify credentials are not configured. See .env.example.";
            } else {
                java.sql.Connection con = null;
                try {
                    con = MysqlCon.getConnection();

                    // Pre-load this org's pond_code -> pond_id map
                    Map<String, Integer> codeToPondId = new HashMap<>();
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT id, code FROM ponds WHERE organization_id = ?")) {
                        ps.setInt(1, orgId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                codeToPondId.put(rs.getString("code").toUpperCase(), rs.getInt("id"));
                            }
                        }
                    }

                    // Pre-load existing shopify_product_id values for this org
                    Set<String> alreadyImported = new HashSet<>();
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT shopify_product_id FROM koi WHERE organization_id = ? AND shopify_product_id IS NOT NULL")) {
                        ps.setInt(1, orgId);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) alreadyImported.add(rs.getString(1));
                        }
                    }

                    List<ShopifyKoiClient.KoiRecord> records =
                            new ShopifyKoiClient().fetchActiveSingleKoiWithRetailTank();

                    String insertSql =
                        "INSERT INTO koi (organization_id, name, age, variety, breeder, sex, size_cm, " +
                        "                 status, pond_id, notes, image_url, shopify_product_id) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 'healthy', ?, ?, ?, ?)";
                    try (PreparedStatement ins = con.prepareStatement(insertSql)) {
                        for (ShopifyKoiClient.KoiRecord r : records) {
                            if (alreadyImported.contains(r.shopifyProductId)) {
                                alreadyHad++;
                                rowReports.add(new String[]{"skipped", r.title, r.retailTank, "already imported"});
                                continue;
                            }
                            Integer pondId = codeToPondId.get(r.retailTank);
                            if (pondId == null) {
                                unknownPond++;
                                rowReports.add(new String[]{"skipped", r.title, r.retailTank,
                                    "no local pond with code '" + r.retailTank + "'"});
                                continue;
                            }
                            try {
                                ins.setInt(1, orgId);
                                ins.setString(2, r.title != null ? r.title : ("Koi " + r.shopifyProductId));
                                if (r.age != null) ins.setInt(3, r.age); else ins.setNull(3, Types.INTEGER);
                                ins.setString(4, r.variety);
                                ins.setString(5, r.breeder);
                                ins.setString(6, r.sex != null ? r.sex : "unknown");
                                if (r.sizeCm != null) ins.setDouble(7, r.sizeCm); else ins.setNull(7, Types.DOUBLE);
                                ins.setInt(8, pondId);
                                ins.setString(9, "Imported from Shopify product " + r.shopifyProductId);
                                ins.setString(10, r.imageUrl);
                                ins.setString(11, r.shopifyProductId);
                                ins.executeUpdate();
                                imported++;
                                rowReports.add(new String[]{"imported", r.title, r.retailTank, "ok"});
                            } catch (SQLException ex) {
                                errors++;
                                rowReports.add(new String[]{"error", r.title, r.retailTank, ex.getMessage()});
                            }
                        }
                    }
                } catch (Exception e) {
                    topError = "Import failed: " + e.getMessage();
                } finally {
                    if (con != null) try { con.close(); } catch (SQLException ignore) {}
                }
            }
        }

        // Summary numbers always shown (for the not-yet-imported state)
        int totalKoi = 0;
        int koiFromShopify = 0;
        java.sql.Connection statsCon = null;
        try {
            statsCon = MysqlCon.getConnection();
            try (PreparedStatement ps = statsCon.prepareStatement(
                    "SELECT COUNT(*) AS total, " +
                    "       COUNT(shopify_product_id) AS from_shopify " +
                    "FROM koi WHERE organization_id = ?")) {
                ps.setInt(1, orgId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) { totalKoi = rs.getInt("total"); koiFromShopify = rs.getInt("from_shopify"); }
                }
            }
        } catch (Exception ignore) {
        } finally {
            if (statsCon != null) try { statsCon.close(); } catch (SQLException ignore) {}
        }
    %>

    <% if (topError != null) { %>
        <div class="alert alert-danger"><%= topError %></div>
    <% } else if (ranImport) { %>
        <div class="alert alert-success">
            Imported <strong><%= imported %></strong>.
            Skipped: <%= alreadyHad %> already had, <%= unknownPond %> unknown pond.
            <% if (errors > 0) { %>Errors: <%= errors %>.<% } %>
        </div>
    <% } %>

    <div class="summary-cards">
        <div class="card">
            <div class="card-label">Shopify Store</div>
            <div class="card-value" style="font-size: 1rem;"><%= shopDomain != null ? shopDomain : "not configured" %></div>
            <div class="card-sub"><%= credsConfigured ? "credentials present" : "missing SHOPIFY_ADMIN_API_TOKEN" %></div>
        </div>
        <div class="card">
            <div class="card-label">Koi (this org)</div>
            <div class="card-value"><%= totalKoi %></div>
            <div class="card-sub">in local database</div>
        </div>
        <div class="card">
            <div class="card-label">From Shopify</div>
            <div class="card-value"><%= koiFromShopify %></div>
            <div class="card-sub">have a shopify_product_id</div>
        </div>
    </div>

    <div class="section">
        <h2>Run Import</h2>
        <p class="card-sub" style="margin-bottom: 1rem;">
            Pulls products from <code><%= shopDomain != null ? shopDomain : "your Shopify store" %></code>
            where <code>product_type = Single_Koi</code>, <code>status = active</code>, and the
            <code>custom.retail_tank</code> metafield matches a local pond code. Already-imported
            koi (matched on Shopify product id) are skipped.
        </p>
        <form method="post" action="import-koi.jsp">
            <input type="hidden" name="action" value="import">
            <button type="submit" class="btn btn-primary" <%= credsConfigured ? "" : "disabled" %>>
                Import from Shopify
            </button>
        </form>
    </div>

    <% if (ranImport && !rowReports.isEmpty()) { %>
        <div class="section">
            <h2>Result Detail (<%= rowReports.size() %> records)</h2>
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Status</th>
                        <th>Name</th>
                        <th>Pond Code</th>
                        <th>Detail</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (String[] row : rowReports) {
                           String badgeCls;
                           if ("imported".equals(row[0])) badgeCls = "badge-good";
                           else if ("error".equals(row[0])) badgeCls = "badge-danger";
                           else badgeCls = "badge-warn";
                    %>
                    <tr>
                        <td><span class="badge <%= badgeCls %>"><%= row[0] %></span></td>
                        <td><%= row[1] != null ? row[1] : "—" %></td>
                        <td><%= row[2] != null ? row[2] : "—" %></td>
                        <td><%= row[3] %></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</main>

<footer>
    <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
</footer>

</body>
</html>
