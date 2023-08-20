

<!--
    Front desk sells and refunds tickets and updates visitor information
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Front desk display article page</title>
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
    <?php
    include 'frontdesk_sidebar.php'
    ?>

    <div class="content">
        <h2>Customer Dashboard</h2>

        <h3>Buy, Refund or Update ticket</h3>
        <form method="GET" id="frontdesk_customers" action="frontdesk_customers.php">
            <select name="ticket-buy-option" id="ticket-buy-option">  
                <option value="ticket-add">Buy</option>
                <option value="ticket-update">Update info</option>
            </select>
            <input type="submit" value="Select" name="frontdesk-choice"></p>
            <br/>
        </form>
    <?php

    include '../shared_functions/database_functions.php';
    include '../shared_functions/print_functions.php';

    function handleDatabaseRequest($request_method) {
        if (connectToDB()) {
            if (array_key_exists('submit-update-ticket', $request_method)) {
                handleUpdateTicketRequest();
            } else if (array_key_exists('submit-add-ticket', $request_method)) {
                handleAddTickettRequest();
            } 
            disconnectFromDB(); 
        }
    }

    function handleUpdateTicketRequest() {
        global $db_conn;

        $name = $_POST['name'];
        $email = $_POST['author'];
        $ticketType = $_POST['ticketType'];
        $ticketID = $_POST['ticket-id'];

        executePlainSQL("MERGE INTO ticket target
            USING visitor
            ON (target.visitor_id = visitor.visitor_id)
            WHEN MATCHED THEN
            UPDATE SET target.ticket_type = '" . $ticketType . "'
            WHERE target.ticket_id = " . $ticketID);
        executePlainSQL("MERGE INTO VISITOR target
            USING TICKET
            ON (TICKET.visitor_id = target.visitor_id)
            WHEN MATCHED THEN
            UPDATE SET target.EMAIL = '" . $email . "',
                    target.NAME = '" . $name . "'
            WHERE TICKET.ticket_id = ". $ticketID);

        echo '<br/><br/>';
        echo 'Ticket updated';

        oci_commit($db_conn);
    }

    function handleAddTickettRequest() {
        global $db_conn;

        $name = $_POST['name'];
        $email = $_POST['author'];
        $visitorID = $_POST['visitor-id'];
        $name = executePlainSQL("SELECT MAX(VISITOR_ID) FROM VISITOR");

        executePlainSQL( "INSERT INTO visitor (visitor_id,name, email) VALUES (" . $visitorID . ", '" . $name . "', '" . $email . "')");

        echo '<br/><br/>';
        echo 'Ticket added';

        oci_commit($db_conn);
    }

    
    function handleFrontdeskRequest() {
        $choice = $_GET['ticket-buy-option'];
        if ($choice == "ticket-add") {
            renderRegisterForm();
        } else if ($choice == "ticket-update") {
            renderUpdateForm();
        }
    }

    function renderRegisterForm() {
        echo '<br/><br/>';
        echo '<p>Please enter visitor and ticket information:</p>';
        echo '<form method="POST" id="frontdesk-add-ticket">';
        echo '<input type="hidden" id="register-visitor-request" name="register-visitor-request">';
        echo 'Visiror ID: <input type="number" name="visitor-id" required> <br/><br/>';
        echo 'Name: <input type="text" name="name" required> <br/><br/>';
        echo 'Email: <input type="text" name="author" required> <br/><br/>';
    
        // Dropdown selection for Ticket type
        echo 'Ticket type: ';
        echo '<select name="ticketType" required>';
        echo '<option value="General Admission">General Admission</option>';
        echo '<option value="Family">Family</option>';
        echo '<option value="Child">Child</option>';
        echo '<option value="Staff">Staff</option>';
        echo '<option value="Senior">Senior</option>';
        echo '</select>';
        echo '<br/><br/>';
    
        echo '<input type="submit" value="Add ticket" name="submit-add-ticket">';
        echo '</form>';
    }

    function renderUpdateForm() {
        echo '<br/><br/>';
        echo '<p>Please enter visitor and ticket information:</p>';
        echo '<form method="POST" id="frontdesk-update-ticket">';
        echo '<input type="hidden" id="update-visitor-request" name="update-visitor-request">';
        echo 'Ticket ID: <input type="number" name="ticket-id" required>';
        echo 'Name: <input type="text" name="name" required> <br/><br/>';
        echo 'Email: <input type="text" name="author" required> <br/><br/>';
    
        // Dropdown selection for Ticket type
        echo 'Ticket type: ';
        echo '<select name="ticketType" required>';
        echo '<option value="General Admission">General Admission</option>';
        echo '<option value="Family">Family</option>';
        echo '<option value="Child">Child</option>';
        echo '<option value="Staff">Staff</option>';
        echo '<option value="Senior">Senior</option>';
        echo '</select>';
        echo '<br/><br/>';
    
        echo '<input type="submit" value="Update ticket" name="submit-update-ticket">';
        echo '</form>';
    }

    // process render form requests
    if(isset($_GET['frontdesk-choice'])) {
        if (array_key_exists('frontdesk-choice', $_GET)) {
            handleFrontdeskRequest();
        }
    }

    // process database requests
    if (isset($_POST['submit-update-ticket']) || isset($_POST['submit-add-ticket'])) {
            handleDatabaseRequest($_POST);
    }


    ?>
</body>
</html>