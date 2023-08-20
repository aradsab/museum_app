

<!--
    Front desk provides viws exhibits and activits
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Front desk display exhibits page</title>
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
    <?php
    include 'frontdesk_sidebar.php'
    ?>
    <div class="content">
        <h2>Count Visitors</h2>

        <h3>Filter Exhibits with Above-Average Attendance in their activities</h3>
        <p>Please enter number of minimum visitors that have attended exhibits</p>
        <form method="POST" id="frontdesk-add-ticket">
        <input type="hidden" id="register-visitor-request" name="register-visitor-request">
        Minimum number of visitors: <input type="number" name="visitor-count" required>
        <input type="submit" value="Count Visitor" name="submit-visitor-count">
        </form>
    <?php

    function handleDatabaseRequest() {
        global $db_conn;
        
        $count = $_POST['visitor-count'];

        $result = executePlainSQL( "SELECT e.exhibit_id, e.exhibit_name
        FROM Exhibit e
        WHERE e.exhibit_id IN (
            SELECT exhibit_id
            FROM attends
            GROUP BY exhibit_id
            HAVING COUNT(*) >
        " . $count . ")");
        
        echo '<br/><br/>';
        echo 'Most viewed exhibits:';
        printResults($result, "auto");
        oci_commit($db_conn);
    }

    // process database requests
    if (isset($_POST['submit-visitor-count'])) {
        handleDatabaseRequest();
    }
    ?>
</body>
</html>