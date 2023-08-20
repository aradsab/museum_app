<!--
    Print functions for outputting database search results to html table
-->

<?php

function printResults($result, $columnNames){
    oci_fetch_all($result, $rows, 0, -1, OCI_FETCHSTATEMENT_BY_ROW);
    
    if ($rows) {
        if ($columnNames === "auto") {
            autogenerateTable($rows);
        } else {
            customTable($rows, $columnNames);
        }   
    } else {
        echo "No results found";
    }
}

function autogenerateTable($rows){ 
    echo "<table>";
    echo "<tr>";

    $ncols = count($rows[0]);
    
    foreach ($rows[0] as $columnName => $value) {
        echo "<th>" . convertToTitleCase($columnName) . "</th>";
    }

    echo "</tr>";

    foreach ($rows as $row) {
        echo "<tr>";
        foreach ($row as $value) {
            echo "<td>" . $value . "</td>";
        } 
        echo "</tr>";
    }

    echo "</table>";
}

function customTable($rows, $columnNames){ 
    echo "<table>";
    echo "<tr>";
        
    foreach ($columnNames as $columnName) {
        echo "<th>" . $columnName . "</th>";
    }

    echo "</tr>";

    foreach ($rows as $row) {
        echo "<tr>";
        foreach ($row as $value) {
            echo "<td>" . $value . "</td>";
        } 
        echo "</tr>";
    }

    echo "</table>";
}

function convertToTitleCase($string) {
    if ($string) {
        // split by delimiter
        $word_arr = explode("_", $string);
        // convert each word to title case
        $word_arr = array_map('strtolower', $word_arr);
        $word_arr = array_map('ucfirst', $word_arr);
        // join array to string
        return implode(" ", $word_arr);
    }
}
?>