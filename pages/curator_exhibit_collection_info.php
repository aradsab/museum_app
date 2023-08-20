<!--
    Curator Exhibit and Collection page
    Can view exhibits and collections based on curator ID (division) and exhibit start and end dates (projection).
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exhibit and Collection Info</title>
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
    <?php
    include 'curator_sidebar.php'
    ?>

    <div class="content">
    <h2>Exhibit and Collection Info</h2>
        <form method="GET" id="curator-exhibit-info-request" action="curator_exhibit_collection_info.php">
            <input type="hidden" id="curator-exhibit-info-request" name="curator-exhibit-info-request">
            <input type="submit" value="Populated Exhibits" name="submit-exhibit-info"></p>
        </form>
        <form method="GET" id="curator-collection-info-request" action="curator_exhibit_collection_info.php">
            <input type="hidden" id="curator-collection-info-request" name="curator-collection-info-request">
            <input type="submit" value="Populated Collections" name="submit-collection-info"></p>
        </form>
        <hr />
        <h2>Curated Works</h2>
        <form method="GET" id="curator-work-request" action="curator_exhibit_collection_info.php">
            <input type="hidden" id="curator-work-request" name="curator-work-request">
            curator SIN: <input type="number" name="curator-sin" min="100000000" max="999999999" required>
            <label for="type">Type:</label>
				<select name="type-option" id="find">
					<option value="exhibit">Exhibit</option>
					<option value="collection">Collection</option>
				</select>
            <input type="submit" value="Find Curated Works" name="submit-curator-work"></p>
        </form>
        <hr />
        <h2>Exhibits by Number of Articles</h2>
        <form method="GET" id="exhibit-article-count" action="curator_exhibit_collection_info.php">
            <input type="hidden" id="exhibit-article-count" name="exhibit-article-count">
            Exhibits with at least <input type="number" name="article-no" min="0" max="99" required> articles
            <input type="submit" value="Find Exhibits" name="submit-article-count"></p>
        </form>
        <hr />
        <h2>List Visitors that Visited Every Exhibit</h2>
        <form method="GET" id="visitors-admitted-to-exhibits" action="curator_exhibit_collection_info.php">
            <input type="submit" value="Display Visitors" name="submit-visitor-admittance"></p>
        </form>
        <hr/>
        
        
        <?php

        include '../shared_functions/database_functions.php';
        include '../shared_functions/print_functions.php';

        function handleDatabaseRequest($request_method) {
            if (connectToDB()) {
                if (array_key_exists('submit-exhibit-info', $request_method)) {
                    handleExhibitInfoRequest();
                } else if (array_key_exists('submit-collection-info', $request_method)) {
                    handleCollectionInfoRequest();
                } else if (array_key_exists('submit-curator-work', $request_method)) {
                    handleCuratorWorkRequest();
                } else if (array_key_exists('submit-article-count', $request_method)) {
                    handleArticleCountRequest();
                } else if (array_key_exists('submit-visitor-admittance', $request_method)) {
                    handleVisitorDisplayRequest();
                }
                disconnectFromDB();
            }
        }

        function handleExhibitInfoRequest() {
            global $db_conn;

            $result = executePlainSQL(
            "SELECT e.exhibit_id, e.exhibit_name, a.article_id, a. article_name, a.article_condition,e.start_date, e.end_date, e.sin
            FROM exhibit e, article a, displays d
            WHERE e.exhibit_id = d.exhibit_id AND a.article_id = d.article_id
            ORDER BY e.exhibit_id");

            echo '<br/><br/>';
            echo 'All Exhibits:';
            printResults($result, "auto");
        }

        function handleCollectionInfoRequest() {
            global $db_conn;

            $result = executePlainSQL(
            "SELECT c.collection_id, c.name, a.article_id, a. article_name , c.sin
            FROM collection c, article a, contains cont
            WHERE c.collection_id = cont.collection_id
            AND a.article_id = cont.article_id
            ORDER BY c.collection_id");

            echo '<br/><br/>';
            echo 'All Collections:';
            printResults($result, "auto");
        }

        function handleCuratorWorkRequest() {
            global $db_conn;

            $curator_sin = $_GET['curator-sin'];
            $dropdown_value = $_GET['type-option'];

            if ($dropdown_value == 'exhibit') {
                $result = executePlainSQL(
                "SELECT DISTINCT e.exhibit_id, e.exhibit_name, a.article_id, a.article_name, a.article_condition, e.start_date, e.end_date, e.sin
                FROM exhibit e, article a, displays d
                WHERE e.sin = " . $curator_sin . " AND
                e.exhibit_id = d.exhibit_id AND
                a.article_id = d.article_id");

                echo '<br/><br/>';
                echo 'All Exhibits by Curator ' . $curator_sin . ':';
                printResults($result, "auto");
            } else if ($dropdown_value == 'collection') {
                $result = executePlainSQL(
                    "SELECT DISTINCT c.collection_id, c.name, a.article_name, c.sin
                    FROM collection c, article a, contains cont
                    WHERE c.sin = " . $curator_sin . " AND 
                    c.collection_id = cont.collection_id AND
                    a.article_id = cont.article_id");
        
                    echo '<br/><br/>';
                    echo 'All Collections by Curator ' . $curator_sin . ':';
                    printResults($result, "auto");
            }
        }

        function handleArticleCountRequest() {
            global $db_conn;

            $article_no = $_GET['article-no'];

            
            $result = executePlainSQL(
            "SELECT e.exhibit_id, e.exhibit_name, e.sin, COUNT(*) AS Number_of_articles
            FROM exhibit e, displays d, article a
            WHERE e.exhibit_id = d.exhibit_id AND d.article_id = a.article_id
            GROUP BY e.exhibit_id, e.exhibit_name, e.sin
            HAVING COUNT(*)>=" . $article_no . " 
            ORDER BY e.exhibit_id");

            echo '<br/><br/>';
            echo 'All Exhibits with at least ' . $article_no . ' articles:';
            printResults($result, "auto");
        }

        function handleVisitorDisplayRequest() {
            global $db_conn;

            $result = executePlainSQL(
            "SELECT v.visitor_id, v.name
            FROM visitor v, ticket t
            WHERE v.visitor_id=t.visitor_id AND
            NOT EXISTS(
                (SELECT e.exhibit_id
                FROM exhibit e)
                MINUS (SELECT a.exhibit_id
                    FROM admits a
                    WHERE a.ticket_id = t.ticket_id))");

            echo '<br/><br/>';
            echo 'The following visitors were admitted to all exhibits:';
            printResults($result, "auto");
        }

        if (isset($_GET['submit-exhibit-info']) || isset($_GET['submit-collection-info']) || isset($_GET['submit-curator-work']) 
            || isset($_GET['submit-article-count']) || isset($_GET['submit-visitor-admittance'])) {
            handleDatabaseRequest($_GET);
        }

        ?>
    </div> 
</body>
</html>