<!--
    Curator Collection Management page
    Can view update, and delete collections (and articles they contain).
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Collection Management</title>
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
    <?php
    include 'curator_sidebar.php'
    ?>

    <div class="content">
        <h2>Add Article to Collection</h2>
        <form method="POST" id="contain-article-request" action="curator_manages_collection.php">
            <input type="hidden" id="contain-article-request" name="collect-article-request">
            article ID: <input type="number" name="article-id" min="00000" max="99999" required>
            <br/><br/>
            collection ID: <input type="number" name="collection-id" min="000" max="999" required>
            <br/><br/>
            <input type="submit" value="Add" name="submit-contain-article">
            </p>
        </form>
        <hr />

        <h2>Remove Article from Collection</h2>
        <form method="POST" id="remove-article-request" action="curator_manages_collection.php">
            <input type="hidden" id="remove-article-request" name="remove-article-request">
            article ID: <input type="number" name="article-id" min="00000" max="99999" required>
            <br/><br/>
            collection ID: <input type="number" name="collection-id" min="000" max="999" required>
            <br/><br/>
            <input type="submit" value="Remove" name="submit-remove-article">
            </p>
        </form>
        <hr />
    
        <?php

        include '../shared_functions/database_functions.php';
        include '../shared_functions/print_functions.php';  

        function handleDatabaseRequest($request_method) {
            if (connectToDB()) {
                if (array_key_exists('submit-contain-article', $request_method)) {
                    handleContainArticleRequest();
                } else if (array_key_exists('submit-remove-article', $request_method)) {
                    handleRemoveArticleRequest();
                }
                disconnectFromDB(); 
            }
        }

        function handleContainArticleRequest() {
            global $db_conn; 

            $article_id = $_POST['article-id'];
            $collection_id = $_POST['collection-id'];

            $tuple_values = array (
                ":article_id" => $article_id,
                ":collection_id" => $collection_id
            );

            $tuple = array ($tuple_values);

            // put article on display in exhibit
            executeBoundSQL(
            "INSERT INTO contains(article_id, collection_id)
            VALUES (:article_id, :collection_id)", $tuple);

            oci_commit($db_conn);

            // generate output for insert into displays 
            $result = executePlainSQL(
                "SELECT a.article_id, a.article_name, c.collection_id, c.name
                FROM article a, contains cont, collection c
                WHERE 
                    a.article_id = " . $article_id . " AND
                    a.article_id = cont.article_id AND
                    c.collection_id = cont.collection_id AND
                    c.collection_id = " . $collection_id);

            echo '<br/><br/>';
            echo 'The following collection has been altered:';
            printResults($result, "auto");
        }

        function handleRemoveArticleRequest() {
            global $db_conn; 

            $collection_id = $_POST['collection-id'];
            $article_id = $_POST['article-id'];

            // delete from displays table 
            $delete_qry = "DELETE 
            FROM contains
            WHERE collection_id = " . $collection_id . " AND 
            article_id = " . $article_id;

            executePlainSQL($delete_qry);

            oci_commit($db_conn);
            
            // removal statement 
            $removed = executePlainSQL(
            "SELECT article_id, article_name, storage_location, date_aquired, article_condition
            FROM article
            WHERE article_id = " . $article_id);

            echo '<br/><br/>';
            echo 'The following article has been removed from a collection:';
            printResults($removed, "auto");
            
        }

        // process database requests
        if (isset($_POST['submit-contain-article']) || isset($_POST['submit-remove-article'])) {
            handleDatabaseRequest($_POST);
        } 
        ?>
    </div>
</body>
</html>