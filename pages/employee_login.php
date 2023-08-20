<!-- 
	Main/login page for museum app
	Access link: https://www.students.cs.ubc.ca/~tineand/museum_app/pages/employee_login.php
	Employees can login by selecting their employee type
-->

<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Employee Login</title>
</head>
<body>
<h1> Museum App </h1>
		<p>Please select your employee type to login:</p>
		<form id="employee-login-form" method="POST" action="employee_redirect.php">
			<label for="employee-type">User type:</label>
				<select name="employee-type" id="employee-type">
					<option value="curator">Curator</option>
					<option value="archivist">Archivist</option>
					<option value="frontdesk">FrontDesk</option>
				</select>
				<br></br>
				<input type="submit" name="login-button" id="login-button" value="Login"/> 
		</form>
</body>
</html>
