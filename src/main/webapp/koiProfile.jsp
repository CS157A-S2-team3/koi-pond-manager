<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Manage Koi Profile - Koi Pond Manager</title>
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
    	<div class="profile-centered-wrapper">
        	<div class="red-form-box">
            	<h2>Koi Profile Details</h2>
            	<form action="saveKoi" method="POST" enctype="multipart/form-data" class="koi-form">
                	<div class="form-group">
                    	<label>Koi Image</label>
                    	<input type="file" name="koi_image" accept="image/*">
                	</div>
                
                	<div class="form-group">
                    	<label>Koi Name</label>
                    	<input type="text" name="name" placeholder="e.g., Sakura" required>
                	</div>

                	<div class="form-row">
                    	<div class="form-group">
                        	<label>Variety</label>
                        	<input type="text" name="variety" placeholder="e.g., Kohaku" required>
                    	</div>
                    	<div class="form-group">
                        	<label>Breeder</label>
                        	<input type="text" name="breeder" placeholder="e.g., Dainichi">
                    	</div>
                	</div>

                	<div class="form-row">
                    	<div class="form-group">
                        	<label>Age (Years)</label>
                        	<input type="number" name="age">
                    	</div>
                    	<div class="form-group">
                        	<label>Sex</label>
                        	<select name="sex">
                            	<option value="Male">Male</option>
                            	<option value="Female">Female</option>
                            	<option value="Unknown">Unknown</option>
                        	</select>
                    	</div>
                	</div>

                	<div class="form-group">
                    	<label>Size (cm)</label>
                    	<input type="number" step="0.01" name="size_cm" required>
                	</div>

                	<div class="form-actions">
                    	<button type="submit" class="add-task-btn">Save Profile</button>
                    	<a href="koi.jsp" class="cancel-link">Cancel</a>
                	</div>
            	</form>
        	</div>
    	</div>
	</main>
	
	<footer>
        <p>&copy; 2026 Koi Pond Manager &mdash; CS157A Team 3</p>
    </footer>

</body>
</html>