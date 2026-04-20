<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — Koi Pond Manager</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <div class="auth-container">
        <div class="auth-card">
            <div class="auth-header">
                <h1>Koi Pond Manager</h1>
                <p>Sign in to your account</p>
            </div>

            <% String error = request.getParameter("error"); %>
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger" style="margin: 0 1.5rem;"><%= error %></div>
            <% } %>

            <form action="login" method="post" class="auth-form">
                <div class="form-group">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" required autofocus>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required>
                </div>

                <button type="submit" class="btn btn-primary btn-block">Sign In</button>
            </form>

            <div class="auth-footer">
                <p>Don't have an account? <a href="signup.jsp">Create one</a></p>
            </div>
        </div>
    </div>

    <footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>
