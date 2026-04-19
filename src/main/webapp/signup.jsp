<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up — Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <div class="auth-container">
        <div class="auth-card auth-card-wide">
            <div class="auth-header">
                <h1>Koi Pond Manager</h1>
                <p>Create your account and organization</p>
            </div>

            <% String error = request.getParameter("error"); %>
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger" style="margin: 0 1.5rem;"><%= error %></div>
            <% } %>

            <form action="signup" method="post" class="auth-form">

                <h3 class="auth-section-title">Your Account</h3>

                <div class="form-row">
                    <div class="form-group">
                        <label for="fullName">Full Name *</label>
                        <input type="text" id="fullName" name="fullName" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="password">Password * <span class="hint">(min 8 characters)</span></label>
                        <input type="password" id="password" name="password" required minlength="8">
                    </div>
                    <div class="form-group">
                        <label for="confirmPassword">Confirm Password *</label>
                        <input type="password" id="confirmPassword" name="confirmPassword" required minlength="8">
                    </div>
                </div>

                <h3 class="auth-section-title">Organization</h3>

                <div class="form-row">
                    <div class="form-group">
                        <label for="orgName">Organization Name *</label>
                        <input type="text" id="orgName" name="orgName" required>
                    </div>
                    <div class="form-group">
                        <label for="timezone">Default Timezone</label>
                        <select id="timezone" name="timezone">
                            <option value="US/Pacific">US/Pacific</option>
                            <option value="US/Mountain">US/Mountain</option>
                            <option value="US/Central">US/Central</option>
                            <option value="US/Eastern">US/Eastern</option>
                            <option value="UTC" selected>UTC</option>
                            <option value="Europe/London">Europe/London</option>
                            <option value="Europe/Berlin">Europe/Berlin</option>
                            <option value="Asia/Tokyo">Asia/Tokyo</option>
                            <option value="Asia/Shanghai">Asia/Shanghai</option>
                            <option value="Australia/Sydney">Australia/Sydney</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="useType">Primary Use Type</label>
                        <select id="useType" name="useType">
                            <option value="hobbyist">Hobbyist</option>
                            <option value="dealer">Dealer</option>
                            <option value="contractor">Contractor</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="unitPreference">Unit Preference</label>
                        <select id="unitPreference" name="unitPreference">
                            <option value="imperial">Imperial (gallons, &deg;F)</option>
                            <option value="metric">Metric (liters, &deg;C)</option>
                        </select>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="stockingDensity">Default Stocking Density</label>
                        <select id="stockingDensity" name="stockingDensity">
                            <option value="conservative">Conservative (hobbyist)</option>
                            <option value="standard" selected>Standard (dealer)</option>
                            <option value="aggressive">Aggressive (wholesale)</option>
                        </select>
                    </div>
                    <div class="form-group"></div>
                </div>

                <button type="submit" class="btn btn-primary btn-block">Create Account</button>
            </form>

            <div class="auth-footer">
                <p>Already have an account? <a href="login.jsp">Sign in</a></p>
            </div>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>
