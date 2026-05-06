<header>
    <h1>Koi Pond Manager</h1>
    <nav>
        <a href="index.jsp">Dashboard</a>
        <a href="ponds.jsp">Ponds</a>
        <a href="koi.jsp">Koi</a>
        <a href="waterTest.jsp">Water</a>
        <a href="treatments.jsp">Treatments</a>
        <a href="maintenance.jsp">Maintenance</a>
        <a href="health.jsp">Health</a>
    </nav>
    <div class="user-menu">
        <span class="user-name"><%= session.getAttribute("fullName") %></span>
        <span class="user-role"><%= session.getAttribute("role") %></span>
        <a href="logout" class="btn-logout">Sign Out</a>
    </div>
</header>
