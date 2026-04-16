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
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>