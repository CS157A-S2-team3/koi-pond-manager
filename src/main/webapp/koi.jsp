<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Koi Inventory Management - Koi Pond Manager</title>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/koi-inventory.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    
    <nav class="navbar">
        <div class="nav-left">
            <a href="index.jsp" class="logo" style="text-decoration: none; color: white;">LOGO HERE???</a>
        </div>
        <div class="nav-middle">
            <div class="search-container">
                <input type="text" placeholder="Search tasks, ponds, or koi...">
                <button type="submit"><i class="fa fa-search"></i></button>
            </div>
            <div class="nav-links">
                <a href="koi.jsp" class="active">Koi</a>
                <a href="ponds.jsp">Ponds</a>
                <a href="treatments.jsp">Treatments</a>
                <a href="logs.jsp">Logs</a>
            </div>
        </div>
        <div class="nav-right">
            <div class="icon-btn" title="View Alerts"><i class="fa fa-bell"></i><span class="badge">3</span></div>
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
    	<div class="container">
        	<header class="inventory-header">
            	<h2>Koi Inventory</h2>
            	<a href="koiProfile.jsp" class="add-task-btn" style="text-decoration: none;">
                	<i class="fa fa-plus"></i> Create New Koi Profile
            	</a>
        	</header>

        	<div class="koi-grid-centered">
            	<div class="koi-card-horizontal">
                	<div class="koi-details-left">
                    	<div class="koi-info">
                        	<h3>Hirasawa (ID: 1)</h3>
                        	<p><strong>Variety:</strong> Kohaku</p>
                        	<p><strong>Breeder:</strong> Hirasawa</p>
                        	<p><strong>Size:</strong> 61.20 cm</p>
                    	</div>
                    	<div class="koi-card-actions">
                        	<a href="koiProfile.jsp?id=1" class="action-btn" style="text-decoration: none;">Update Profile</a>
                    	</div>
                	</div>
                	<div class="koi-image-right">
                    	<img src="https://via.placeholder.com/200x200.png?text=Koi+Image" alt="Koi ID 1">
                	</div>
            	</div>
        	</div>
    	</div>
	</main>

</body>
</html>