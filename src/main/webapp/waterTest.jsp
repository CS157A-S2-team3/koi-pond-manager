<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Water Quality Logging</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        .page-top {
            margin-bottom: 2rem;
        }

        .page-top h2 {
            font-size: 1.6rem;
        }

        .breadcrumbs {
            font-size: 0.9rem;
            color: #6c757d;
            margin-bottom: 0.5rem;
        }

        .breadcrumbs a {
            color: inherit;
            text-decoration: none;
        }

        .page-description {
            color: #6c757d;
            margin-top: 0.5rem;
        }

        .top-cards {
            margin-bottom: 2rem;
        }

        .content-layout {
            display: grid;
            grid-template-columns: 2.3fr 0.9fr;
            gap: 2rem;
            align-items: start;
        }

        .note-box {
            background: #f8f9fa;
            border-left: 4px solid #0d6efd;
            padding: 1rem;
            border-radius: 8px;
            margin: 1rem 0 1.5rem 0;
            color: #495057;
        }

        .form-layout {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem 1.5rem;
        }

        .full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.4rem;
        }

        .form-group input,
        .form-group textarea {
            width: 100%;
            padding: 0.8rem;
            border: 1px solid #ced4da;
            border-radius: 8px;
            font: inherit;
            background: white;
        }

        .form-group input:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #86b7fe;
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
        }

        input:hover,
        textarea:hover {
            border-color: #adb5bd;
        }

        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }

        .help-text {
            display: block;
            margin-top: 0.35rem;
            font-size: 0.82rem;
            color: #6c757d;
        }

        .button-row {
            display: flex;
            gap: 0.75rem;
            margin-top: 1.25rem;
            flex-wrap: wrap;
        }

        .main-button,
        .cancel-button {
            padding: 0.75rem 1.1rem;
            border-radius: 8px;
            border: none;
            font: inherit;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
        }

        .main-button {
            background: #0d6efd;
            color: white;
        }

        .main-button:hover {
            background: #0b5ed7;
        }

        .cancel-button {
            background: #e9ecef;
            color: #212529;
        }

        .cancel-button:hover {
            background: #dee2e6;
        }

        .range-list {
            display: grid;
            gap: 0.8rem;
        }

        .range-box {
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            background: #ffffff;
        }

        .range-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.4rem;
            gap: 0.5rem;
        }

        .range-name {
            font-weight: 600;
        }

        .range-text {
            margin: 0;
            font-size: 0.9rem;
            color: #6c757d;
        }

        .tag {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 0.25rem 0.55rem;
            border-radius: 999px;
            text-transform: uppercase;
        }

        .green {
            background: #d1e7dd;
            color: #0f5132;
        }

        .yellow {
            background: #fff3cd;
            color: #664d03;
        }

        .red {
            background: #f8d7da;
            color: #842029;
        }

        .history-link {
            display: inline-block;
            margin-top: 1rem;
            font-weight: 600;
            text-decoration: none;
        }

        .small-note {
            margin-top: 1rem;
            font-size: 0.85rem;
            color: #6c757d;
        }

        @media (max-width: 900px) {
            .content-layout {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 700px) {
            .form-layout,
            .top-cards {
                grid-template-columns: 1fr;
            }
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

    <main>
        <div class="page-top">
            <div class="breadcrumbs">
                <a href="index.jsp">Dashboard</a> / Water Quality / Log Test
            </div>
            <h2>Water Quality Logging</h2>
            <p class="page-description">
                Record pond test readings and monitor safe water ranges.
            </p>
        </div>

        <div class="summary-cards top-cards">
            <div class="card">
                <div class="card-label">pH Target</div>
                <div class="card-value">6.5–8.5</div>
                <div class="card-sub">Ideal range</div>
            </div>

            <div class="card">
                <div class="card-label">Ammonia</div>
                <div class="card-value">&lt; 0.25</div>
                <div class="card-sub">Keep low</div>
            </div>

            <div class="card">
                <div class="card-label">Nitrite / Nitrate</div>
                <div class="card-value">&lt; 0.25 / &lt; 40</div>
                <div class="card-sub">Watch trends</div>
            </div>
        </div>

        <div class="content-layout">
            <div class="section">
                <h2>Water Test Entry</h2>
                <p class="page-description">Enter the latest test values below.</p>

                <div class="note-box">
                    Values outside the recommended range should still be reviewed, even if they are accepted as valid input.
                </div>

                <form action="waterTest" method="post">
                    <div class="form-layout">
                        <div class="form-group">
                            <label for="pondId">Pond ID</label>
                            <input type="number" id="pondId" name="pondId" min="1" required>
                            <span class="help-text">Required</span>
                        </div>

                        <div class="form-group">
                            <label for="userId">Recorded By User ID</label>
                            <input type="number" id="userId" name="userId" min="1" required>
                            <span class="help-text">Required</span>
                        </div>

                        <div class="form-group">
                            <label for="ph">pH</label>
                            <input type="number" id="ph" name="ph" step="0.01" min="0" max="14" required>
                            <span class="help-text">Valid: 0–14</span>
                        </div>

                        <div class="form-group">
                            <label for="temperature">Temperature (°F)</label>
                            <input type="number" id="temperature" name="temperature" step="0.01" min="32" max="120" required>
                            <span class="help-text">Valid: 32–120</span>
                        </div>

                        <div class="form-group">
                            <label for="ammonia">Ammonia</label>
                            <input type="number" id="ammonia" name="ammonia" step="0.01" min="0" required>
                            <span class="help-text">Recommended: under 0.25</span>
                        </div>

                        <div class="form-group">
                            <label for="nitrite">Nitrite</label>
                            <input type="number" id="nitrite" name="nitrite" step="0.01" min="0" required>
                            <span class="help-text">Recommended: under 0.25</span>
                        </div>

                        <div class="form-group full-width">
                            <label for="nitrate">Nitrate</label>
                            <input type="number" id="nitrate" name="nitrate" step="0.01" min="0" required>
                            <span class="help-text">Recommended: under 40</span>
                        </div>

                        <div class="form-group full-width">
                            <label for="notes">Notes</label>
                            <textarea id="notes" name="notes" placeholder="Add observations on koi fish.. maintenance notes..."></textarea>
                            <span class="help-text">Optional</span>
                        </div>
                    </div>

                    <div class="button-row">
                        <button type="submit" class="main-button">Submit Water Test</button>
                        <a href="index.jsp" class="cancel-button">Cancel</a>
                    </div>
                </form>

                <a class="history-link" href="waterHistory.jsp">View Water Test History →</a>
            </div>

            <div class="section">
                <h2>Recommended Ranges</h2>

                <div class="range-list">
                    <div class="range-box">
                        <div class="range-top">
                            <div class="range-name">pH</div>
                            <span class="tag green">Ideal</span>
                        </div>
                        <p class="range-text">Recommended: 6.5–8.5</p>
                    </div>

                    <div class="range-box">
                        <div class="range-top">
                            <div class="range-name">Ammonia</div>
                            <span class="tag red">High Risk</span>
                        </div>
                        <p class="range-text">Target: below 0.25</p>
                    </div>

                    <div class="range-box">
                        <div class="range-top">
                            <div class="range-name">Nitrite</div>
                            <span class="tag yellow">Monitor</span>
                        </div>
                        <p class="range-text">Keep below 0.25</p>
                    </div>

                    <div class="range-box">
                        <div class="range-top">
                            <div class="range-name">Nitrate</div>
                            <span class="tag yellow">Trend</span>
                        </div>
                        <p class="range-text">Keep below 40</p>
                    </div>

                    <div class="range-box">
                        <div class="range-top">
                            <div class="range-name">Temperature</div>
                            <span class="tag green">Seasonal</span>
                        </div>
                        <p class="range-text">Typical koi-safe range: 50–85°F</p>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>
</body>
</html>