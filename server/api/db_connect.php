<?php
// FILE: db_connect.php (for LOCAL XAMPP testing)

// Allow requests from any origin (important for mobile app testing)
header("Access-Control-Allow-Origin: *");
// Set the content type to JSON, as our scripts will always return JSON
header("Content-Type: application/json; charset=UTF-8");

// --- XAMPP/MariaDB Default Connection Details ---
$servername = "";
$username = "";     // The default username for XAMPP's database
$password = "";         // The default password for XAMPP is emptyy
$dbname = "";

try {
    // For XAMPP, we create a MySQL connection string
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    
    // Set the PDO error mode to exception. This is a best practice.
    // It means if something goes wrong, the script will stop and show a clear error.
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

} catch (PDOException $e) {
    // If the connection fails for any reason, stop the script and report the error.
    // The die() function is very useful for debugging.
    die("Connection failed: " . $e->getMessage());
}

// If the script gets past this point, the $conn variable holds a
// successful, open connection to your database.
?>
