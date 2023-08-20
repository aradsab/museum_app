<!--
    Archivist display article page
    Archivist can search exhibits and activities, find articles currently on display in an exhibit, count articles
    currently on display in each exhibit, put articles on display, and calculate the profit per exhibit
-->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Archivist display article</title>
    <link rel="stylesheet" type="text/css" href="../css/style.css">
</head>
<body>
    <?php
    include 'archivist_sidebar.php'
    ?>

    <div class="content">
        <h2>Articles on Display</h2>

        <h3>Search Exhibits and Activities</h3>
        <form method="GET" id="archivist-search-exhibit-request" action="archivist_display_article.php">
            <input type="hidden" id="archivist-search-exhibit-request" name="archivist-search-exhibit-request">
            <label for="search">Find:</label>
				<select name="search-option" id="search">
					<option value="exhibit-search">Exhibits</option>
					<option value="activity-search">Activities</option>
				</select>
			<br/><br/>
            <input type="submit" value="Search" name="submit-search-exhibit"></p>
            <br/>
        </form>

        <h3>Current Articles on Display</h3>
        <form method="GET" id="find-article-on-display-request" action="archivist_display_article.php">
            <input type="hidden" id="find-article-on-display-request" name="find-article-on-display-request">
            exhibit ID: <input type="number" name="exhibit-id-find-article" min="1000" max="9999" required>
            <input type="submit" value="Find Articles" name="submit-find-article-on-display"></p>
</br>
        </form>

        <h3>Visitors Per Exhibit</h3>
        <form method="GET" id="count-article-on-display-request" action="archivist_display_article.php">
            <input type="hidden" id="count-article-on-display-request" name="count-article-on-display-request">
            Number of visitors per exhibit
            <input type="submit" value="Count" name="submit-count-article-on-display"></p>
            <br/>
        </form>

        <h3>Add Article to Exhibit</h3>
        <form method="POST" id="add-article-to-exhibit-request" action="archivist_display_article.php">
            <input type="hidden" id="add-article-to-exhibit-request" name="add-article-to-exhibit-request">
            exhibit ID: <input type="number" name="exhibit-id-display-article" min="1000" max="9999" required>
            <br/><br/>
            article ID: <input type="number" name="article-id" min="10000" max="99999" required>
            <br/><br/>
            <input type="submit" value="Add Article" name="submit-add-article-to-exhibit"></p>
            <br/>
        </form>
    
        <h3>Revenue From Exhibits</h3>
        <form method="GET" id="find-revenue-per-exhibit-request" action="archivist_display_article.php">
            <input type="hidden" id="find-revenue-per-exhibit-request" name="find-revenue-per-exhibit-request">
            With at least <input type="number" name="num-visitors-per-exhibit" min="1" max="9999" required> visitor(s)
            <br/><br/>
            <input type="submit" value="Calculate" name="submit-find-revenue-per-exhibit"></p>
            <br/><br/>
        </form>

        <?php

        include '../shared_functions/database_functions.php';
        include '../shared_functions/print_functions.php';

        function handleDatabaseRequest($request_method) {
            if (connectToDB()) {
            if (array_key_exists('submit-search-exhibit', $request_method)) {
                handleSearchExhibitsRequest();
            } else if  (array_key_exists('submit-exhibit-search-condition', $request_method)) {
                handleSearchExhibitByConditionRequest();
            } else if  (array_key_exists('submit-activity-search-condition', $request_method)) {
                handleSearchActivityByConditionRequest();
            }else if (array_key_exists('submit-find-article-on-display', $request_method)) {
                handleFindArticlesOnDisplayRequest();
            } else if (array_key_exists('submit-count-article-on-display', $request_method)) {
                handleCountArticlesOnDisplayRequest();
            } else if  (array_key_exists('submit-add-article-to-exhibit', $request_method)) {
                handleAddArticleToExhibitRequest();
            } else if  (array_key_exists('submit-find-revenue-per-exhibit', $request_method)) {
                handleFindRevenuePerExhibitRequest();
            }
            disconnectFromDB(); 
            }
        }

        function handleSearchExhibitsRequest() {
            global $db_conn;
            $dropdown_value = $_GET['search-option'];

            if ($dropdown_value == 'exhibit-search') {
                renderExhibitSearchForm();
            } else if ($dropdown_value == 'activity-search') {
                renderActivitySearchForm();
            } else {
                echo "Please select a search option.";
            }
        }

        function handleSearchExhibitByConditionRequest() {
            global $db_conn;

            $search_option = "exhibits";
            $table = "exhibit";
            $columns = "exhibit_id, exhibit_name, start_date, end_date";
            $exhibit_name = $_GET['exhibit-name'];
            $start_date = $_GET['start-date'];
            $end_date = $_GET['end-date'];

            $values = [$exhibit_name, $start_date, $end_date];
            $conditions = [];

            if (!empty($exhibit_name)) {
                $conditions[] = "UPPER(exhibit_name) LIKE '%' || UPPER('" . $exhibit_name . "') || '%'";
            }

            if (!empty($start_date)) {
                $conditions[] = "start_date > TO_DATE('" . $start_date . "', 'YYYY-MM-DD')";
            }

            if (!empty($end_date)) {
                $conditions[] = "end_date < TO_DATE('" . $end_date . "', 'YYYY-MM-DD')";
            }

            if (!empty($conditions)) {
                $query = implode(' AND ', $conditions);
                searchTableGivenQuery($search_option, $columns, $table, $query);
            } else {
                echo 'Please enter a search condition.';
            }
        }

        function handleSearchActivityByConditionRequest() {
            global $db_conn;

            $search_option = "activities";
            $table = "exhibit e, activities a";
            $columns = "e.exhibit_id, e.exhibit_name, a.name, a.schedule";
            $activity_name = $_GET['activity-name'];
            $day_of_the_week = $_GET['day-of-the-week'];

            $values = [$activity_name, $day_of_the_week];
            $conditions = [];

            if (!empty($activity_name)) {
                $conditions[] = "UPPER(a.name) LIKE '%' || UPPER('" . $activity_name . "') || '%'";
            }

            if (!empty($day_of_the_week)) {
                $conditions[] = "UPPER(a.schedule) LIKE '%' || UPPER('" . $day_of_the_week . "') || '%'";
            }

            if (!empty($conditions)) {
                $conditions[] = "e.exhibit_id = a.exhibit_id";
                $query = implode(' AND ', $conditions);
                searchTableGivenQuery($search_option, $columns, $table, $query);
            } else {
                echo 'Please enter a search condition.';
            }
        }

        function searchTableGivenQuery($search_option, $columns, $table, $query) {
            $result = executePlainSQL(
                "SELECT ". $columns ."
                FROM " . $table . "
                WHERE " . $query);
    
            echo '<p>The following ' . $search_option . ' match the given conditions:</p>';
            printResults($result, "auto");
        }

        function handleFindArticlesOnDisplayRequest() {
            global $db_conn;

            $exhibit_id = $_GET['exhibit-id-find-article'];

            $result = executePlainSQL(
                "SELECT 
                    e.exhibit_id, e.exhibit_name, e.start_date, e.end_date,
                    a.article_id, a.article_name, a.storage_location
                FROM exhibit e, displays d, article a
                WHERE
                    e.exhibit_id = " . $exhibit_id . " AND
                    e.exhibit_id = d.exhibit_id AND
                    d.article_id = a.article_id");

            echo '<p>The following articles are currently on display:</p>';
            printResults($result, "auto");
        }

        function handleCountArticlesOnDisplayRequest() {
            global $db_conn;

            $result = executePlainSQL(
                "SELECT e.exhibit_id, COUNT(*)
                FROM exhibit e, admits a, ticket t
                WHERE e.exhibit_id = a.exhibit_id AND a.ticket_id = t.ticket_id
                GROUP BY e.exhibit_id
                ORDER BY e.exhibit_id");

            echo '<p>The number of visitors who have visited each exhibit is:</p>';
            printResults($result, ["Exhibit ID", "Number of Visitors"]);
        }

        function handleAddArticleToExhibitRequest() {
            global $db_conn; 

            $exhibit_id = $_POST['exhibit-id-display-article'];
            $article_id = $_POST['article-id'];

            // if article does not already exist in exhibit, insert it
            $insert_result = executePlainSQL(
                "MERGE INTO displays target
                USING (SELECT " . $exhibit_id . " AS eoi, " . $article_id . " AS aoi FROM dual) source
                ON (target.exhibit_id = source.eoi AND target.article_id = source.aoi)
                WHEN NOT MATCHED THEN
                    INSERT (exhibit_id, article_id)
                    VALUES (source.eoi, source.aoi)");

            $rows = oci_num_rows($insert_result);
            // if a row was inserted, update article location to on display
            if ($rows > 0) {
                executePlainSQL(
                    "UPDATE article
                    SET storage_location = 'on display'
                    WHERE article_id = " . $article_id);
                
                printArticleOnDisplay($article_id, $exhibit_id, '<p>The following article has been put on display:</p>');
            } else {
                echo '<p>Article ' . $article_id . ' is already on display in exhibit ' . $exhibit_id . '.</p>';
            }

            oci_commit($db_conn);            
        }

        function handleFindRevenuePerExhibitRequest() {
            global $db_conn;

            $num_visitors = $_GET['num-visitors-per-exhibit'];

            $result = executePlainSQL(
                "SELECT e.exhibit_id, SUM(tp.price)
                FROM ticket t, ticketprice tp, visitor v, admits a, exhibit e
                WHERE
                    t.ticket_type = tp.ticket_type AND
                    t.visitor_id = v.visitor_id AND
                    t.ticket_id = a.ticket_id AND
                    a.exhibit_id = e.exhibit_id
                GROUP BY e.exhibit_id
                HAVING " . $num_visitors . " <= (
                    SELECT COUNT(*)
                    FROM ticket t1, visitor v1, admits a1, exhibit e1
                    WHERE
                        t1.visitor_id = v1.visitor_id AND
                        t1.ticket_id = a1.ticket_id AND
                        a1.exhibit_id = e1.exhibit_id AND
                        e1.exhibit_id = e.exhibit_id)");

            echo '<p>The total revenue per exhibit with at least ' . $num_visitors . ' visitors is:</p>';
            printResults($result, ["Exhibit ID", "Total Revenue"]);
        }

        function renderExhibitSearchForm() {
            echo '<p>Please enter the the search conditions:</p>';
            echo '<p>Enter dates in the format YYYY-MM-DD</p>';
            echo '<form method="GET" id="archivist-search-exhibit-condition">';
            echo '<input type="hidden" id="archivist-search-exhibit-request" name="archivist-search-exhibit-request">';
            echo 'Name <input type="text" name="exhibit-name">  <br/><br/>';
            echo 'Starts After <input type="text" name="start-date">  <br/><br/>';
            echo 'Ends Before <input type="text" name="end-date"> <br/><br/>';
            echo '<input type="submit" value="Search" name="submit-exhibit-search-condition"></p>';
            echo '</form>';
        }

        function renderActivitySearchForm() {
            echo '<p>Please enter the the search conditions:</p>';
            echo '<form method="GET" id="archivist-search-activity-condition">';
            echo '<input type="hidden" id="archivist-search-activity-request" name="archivist-search-activity-request">';
            echo 'Name <input type="text" name="activity-name">  <br/><br/>';
            echo 'Day of the week <input type="text" name="day-of-the-week">  <br/><br/>';
            echo '<input type="submit" value="Search" name="submit-activity-search-condition"></p>';
            echo '</form>';
        }

        function printArticleOnDisplay($article_id, $exhibit_id, $output_string) {
            $result = executePlainSQL(
                "SELECT 
                    e.exhibit_id, e.exhibit_name,
                    a.article_id, a.article_name, a.storage_location
                FROM article a, displays d, exhibit e
                WHERE 
                    a.article_id = " . $article_id . " AND
                    a.article_id = d.article_id AND
                    d.exhibit_id = e.exhibit_id AND
                    e.exhibit_id = " . $exhibit_id);

            echo $output_string;
            printResults($result, "auto");
        }

        // process database requests
        if (isset($_POST['submit-add-article-to-exhibit'])) {
            handleDatabaseRequest($_POST);
        } else if (isset($_GET['submit-search-exhibit']) || isset($_GET['submit-exhibit-search-condition']) || isset($_GET['submit-activity-search-condition']) 
        || isset($_GET['submit-find-article-on-display']) || isset($_GET['submit-count-article-on-display']) || isset($_GET['submit-find-revenue-per-exhibit'])) {
            handleDatabaseRequest($_GET);
        }
        ?>
    </div>
</body>
</html>
