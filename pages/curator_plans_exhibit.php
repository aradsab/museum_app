<!--
    Curator Exhibit Planning page
    Can view update, and delete exhibits (and articles on display).
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exhibit Planning</title>
    <link rel="stylesheet" type="text/css" href="./css/style.css">
    <!-- TODO: put ../ back in front of include statements -->
</head>
<body>
    <?php
    include 'curator_sidebar.php'
    ?>

    <div class="content">
        <h2>Display Article in Exhibit</h2>
        <form method="POST" id="display-article-request" action="curator_plans_exhibit.php">
            <input type="hidden" id="display-article-request" name="display-article-request">
            article ID: <input type="number" name="article-id" min="00000" max="99999" required>
            <br/><br/>
            exhibit ID: <input type="number" name="exhibit-id" min="0000" max="9999" required>
            <br/><br/>
            <input type="submit" value="Display" name="submit-display-article">
            </p>
        </form>
        <hr />

        <h2>Remove Article from Exhibit</h2>
        <form method="POST" id="remove-article-request" action="curator_plans_exhibit.php">
            <input type="hidden" id="remove-article-request" name="remove-article-request">
            article ID: <input type="number" name="article-id" min="00000" max="99999" required>
            <br/><br/>
            exhibit ID: <input type="number" name="exhibit-id" min="0000" max="9999" required>
            <br/><br/>
            <input type="submit" value="Remove" name="submit-remove-article">
            </p>
        </form>
        <hr />
    
        <?php

        include './shared_functions/database_functions.php';
        include './shared_functions/print_functions.php';
        //TODO: put ../ back in front of include statements  

        function handleDatabaseRequest($request_method) {
            if (connectToDB()) {
                if (array_key_exists('submit-display-article', $request_method)) {
                    handleDisplayArticleRequest();
                } else if (array_key_exists('submit-remove-article', $request_method)) {
                    handleRemoveArticleRequest();
                }
                disconnectFromDB(); 
            }
        }

        function handleDisplayArticleRequest() {
            global $db_conn; 

            $article_id = $_POST['article-id'];
            $exhibit_id = $_POST['exhibit-id'];

            $tuple_values = array (
                ":exhibit_id" => $exhibit_id,
                ":article_id" => $article_id
            );

            $tuple = array ($tuple_values);

            // put article on display in exhibit
            executeBoundSQL(
            "INSERT INTO displays(exhibit_id, article_id)
            VALUES (:exhibit_id, :article_id)", $tuple);
            
            // update article location to on display
            if($success){
                // update location of article
                $update_qry = "UPDATE article
                SET storage_location = 'on display'
                WHERE article_id = " . $article_id;
    
                executePlainSQL($update_qry);
            }

            oci_commit($db_conn);

            // generate output for insert into displays 
            $result = executePlainSQL(
                "SELECT a.article_id, a.article_name, a.storage_location,
                        e.exhibit_id, e.exhibit_name
                FROM article a, displays d, exhibit e
                WHERE 
                    a.article_id = " . $article_id . " AND
                    a.article_id = d.article_id AND
                    d.exhibit_id = e.exhibit_id AND
                    e.exhibit_id = " . $exhibit_id);

            echo '<br/><br/>';
            echo 'The following has been displayed:';
            printResults($result, "auto");
        }

        function handleRemoveArticleRequest() {
            global $db_conn;
            global $success; 

            $exhibit_id = $_POST['exhibit-id'];
            $article_id = $_POST['article-id'];

            // delete from displays table 
            $delete_qry = "DELETE 
            FROM displays
            WHERE exhibit_id = " . $exhibit_id ." AND 
            article_id = " . $article_id;

            executePlainSQL($delete_qry);

            if($success){
            // update location of article
            $update_qry = "UPDATE article
            SET storage_location = 'main storage room'
            WHERE article_id = " . $article_id;

            executePlainSQL($update_qry);
            }

            oci_commit($db_conn);
            
            // removal statement 
            $removed = executePlainSQL(
            "SELECT article_id, article_name, storage_location
            FROM article
            WHERE article_id = " . $article_id);

            echo '<br/><br/>';
            echo 'The following article has been placed back into storage:';
            printResults($removed, "auto");
            
        }

        // process database requests
        if (isset($_POST['submit-display-article']) || isset($_POST['submit-remove-article'])) {
            handleDatabaseRequest($_POST);
        } 
        ?>
    </div>
</body>
</html>