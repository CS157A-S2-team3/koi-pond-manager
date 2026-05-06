package com.koi;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

// Calls the Shopify Admin GraphQL API to list Single_Koi products. Filters at the
// query level by product type and status; the retail_tank check happens after fetch
// (Shopify search syntax for metafields varies and isn't reliable across stores).
//
// Authenticates with a custom-app Admin API access token from EnvLoader.
public class ShopifyKoiClient {
    private static final String API_VERSION = "2026-01";
    private static final int PAGE_SIZE = 50;

    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(10))
            .build();

    public static class KoiRecord {
        public String shopifyProductId;   // numeric portion of gid
        public String title;
        public String variety;
        public String breeder;
        public String retailTank;         // pond code, e.g. "C2"
        public String sex;                // normalized to male/female/unknown
        public Integer age;
        public Double sizeCm;
        public String imageUrl;           // featuredImage.url, may be null
    }

    public List<KoiRecord> fetchActiveSingleKoiWithRetailTank() throws Exception {
        String shopDomain = EnvLoader.require("SHOPIFY_SHOP_DOMAIN");
        String token      = EnvLoader.require("SHOPIFY_ADMIN_API_TOKEN");
        String url = "https://" + shopDomain + "/admin/api/" + API_VERSION + "/graphql.json";

        List<KoiRecord> records = new ArrayList<>();
        String cursor = null;
        boolean hasNext = true;

        while (hasNext) {
            String body = buildRequestBody(cursor);
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(30))
                    .header("Content-Type", "application/json")
                    .header("X-Shopify-Access-Token", token)
                    .POST(HttpRequest.BodyPublishers.ofString(body, StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            if (resp.statusCode() / 100 != 2) {
                throw new RuntimeException("Shopify HTTP " + resp.statusCode() + ": " + resp.body());
            }

            Object parsed = JsonParser.parse(resp.body());
            Map<String, Object> root = asMap(parsed);
            Object errors = root.get("errors");
            if (errors != null) {
                throw new RuntimeException("Shopify GraphQL errors: " + errors);
            }

            Map<String, Object> data = asMap(root.get("data"));
            Map<String, Object> products = asMap(data.get("products"));
            List<Object> edges = asList(products.get("edges"));

            for (Object edgeObj : edges) {
                Map<String, Object> edge = asMap(edgeObj);
                Map<String, Object> node = asMap(edge.get("node"));
                KoiRecord rec = mapNodeToRecord(node);
                if (rec != null && rec.retailTank != null && !rec.retailTank.isEmpty()) {
                    records.add(rec);
                }
            }

            Map<String, Object> pageInfo = asMap(products.get("pageInfo"));
            hasNext = Boolean.TRUE.equals(pageInfo.get("hasNextPage"));
            cursor = (String) pageInfo.get("endCursor");
        }

        return records;
    }

    private String buildRequestBody(String afterCursor) {
        // status:active narrows at the query level; product_type pins to single koi.
        // Keep retail_tank filtering client-side (see class comment).
        String afterArg = afterCursor == null ? "null" : "\"" + escapeJson(afterCursor) + "\"";
        String query =
            "query KoiPondManager_FetchSingleKoi($first: Int!, $query: String!, $after: String) {" +
            "  products(first: $first, query: $query, after: $after, sortKey: TITLE) {" +
            "    pageInfo { hasNextPage endCursor }" +
            "    edges {" +
            "      node {" +
            "        id title vendor" +
            "        featuredImage { url }" +
            "        metafields(first: 50, namespace: \"custom\") {" +
            "          nodes { key value }" +
            "        }" +
            "        variants(first: 1) {" +
            "          nodes {" +
            "            id" +
            "            metafields(first: 50, namespace: \"custom\") {" +
            "              nodes { key value }" +
            "            }" +
            "          }" +
            "        }" +
            "      }" +
            "    }" +
            "  }" +
            "}";

        StringBuilder sb = new StringBuilder();
        sb.append("{\"query\":\"").append(escapeJson(query)).append("\",")
          .append("\"variables\":{")
          .append("\"first\":").append(PAGE_SIZE).append(",")
          .append("\"query\":\"product_type:Single_Koi status:active\",")
          .append("\"after\":").append(afterArg)
          .append("}}");
        return sb.toString();
    }

    private KoiRecord mapNodeToRecord(Map<String, Object> node) {
        if (node == null) return null;
        KoiRecord rec = new KoiRecord();
        rec.shopifyProductId = stripGidPrefix((String) node.get("id"));
        rec.title = (String) node.get("title");

        Map<String, Object> featuredImage = asMap(node.get("featuredImage"));
        Object imgUrl = featuredImage.get("url");
        if (imgUrl instanceof String) rec.imageUrl = (String) imgUrl;

        Map<String, Object> productMetafields = asMap(node.get("metafields"));
        for (Map<String, Object> mf : asMapList(productMetafields.get("nodes"))) {
            String key = (String) mf.get("key");
            String val = (String) mf.get("value");
            if (val == null) continue;
            switch (key) {
                case "variety":      rec.variety = val; break;
                case "breeder":      rec.breeder = val; break;
                case "retail_tank":  rec.retailTank = val.trim().toUpperCase(); break;
                default: /* ignore */ break;
            }
        }

        Map<String, Object> variants = asMap(node.get("variants"));
        List<Map<String, Object>> variantNodes = asMapList(variants.get("nodes"));
        if (!variantNodes.isEmpty()) {
            Map<String, Object> variantMetafields = asMap(variantNodes.get(0).get("metafields"));
            for (Map<String, Object> mf : asMapList(variantMetafields.get("nodes"))) {
                String key = (String) mf.get("key");
                String val = (String) mf.get("value");
                if (val == null) continue;
                switch (key) {
                    case "sex":
                        rec.sex = normalizeSex(val);
                        break;
                    case "age":
                        rec.age = parseIntSafe(val);
                        break;
                    case "variant_size_in_cm":
                        rec.sizeCm = parseDoubleSafe(val);
                        break;
                    default: /* ignore */ break;
                }
            }
        }
        return rec;
    }

    private static String stripGidPrefix(String gid) {
        if (gid == null) return null;
        int slash = gid.lastIndexOf('/');
        return slash >= 0 ? gid.substring(slash + 1) : gid;
    }

    private static String normalizeSex(String raw) {
        if (raw == null) return "unknown";
        String s = raw.trim().toLowerCase();
        if (s.startsWith("m")) return "male";
        if (s.startsWith("f")) return "female";
        return "unknown";
    }

    private static Integer parseIntSafe(String s) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return null; }
    }

    private static Double parseDoubleSafe(String s) {
        try { return Double.parseDouble(s.trim()); } catch (Exception e) { return null; }
    }

    @SuppressWarnings("unchecked")
    private static Map<String, Object> asMap(Object o) {
        return o instanceof Map ? (Map<String, Object>) o : java.util.Collections.emptyMap();
    }

    @SuppressWarnings("unchecked")
    private static List<Object> asList(Object o) {
        return o instanceof List ? (List<Object>) o : java.util.Collections.emptyList();
    }

    @SuppressWarnings("unchecked")
    private static List<Map<String, Object>> asMapList(Object o) {
        List<Map<String, Object>> out = new ArrayList<>();
        if (!(o instanceof List)) return out;
        for (Object item : (List<Object>) o) {
            if (item instanceof Map) out.add((Map<String, Object>) item);
        }
        return out;
    }

    private static String escapeJson(String s) {
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        return sb.toString();
    }
}
