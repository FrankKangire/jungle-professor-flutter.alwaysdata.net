<?php

include 'db_connect.php';

header('Content-Type: application/json');

// Check required fields
if (
    !isset($_POST['username']) ||
    !isset($_POST['email']) ||
    !isset($_POST['password'])
) {
    echo json_encode([
        "status" => "error",
        "message" => "Username, email and password are required."
    ]);
    exit();
}

$username = trim($_POST['username']);
$email = trim($_POST['email']);
$password = $_POST['password'];

// Prevent empty submissions
if (empty($username) || empty($email) || empty($password)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username, email and password cannot be empty."
    ]);
    exit();
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => "error",
        "message" => "Please enter a valid email address."
    ]);
    exit();
}

$hashed_password = password_hash($password, PASSWORD_DEFAULT);

try {

    // Check whether username already exists
    $stmt = $conn->prepare(
        "SELECT id FROM users WHERE username = ?"
    );

    $stmt->execute([$username]);

    if ($stmt->fetch()) {
        echo json_encode([
            "status" => "error",
            "message" => "Username already exists."
        ]);
        exit();
    }

    // Check whether email already exists
    $stmt = $conn->prepare(
        "SELECT id FROM users WHERE email = ?"
    );

    $stmt->execute([$email]);

    if ($stmt->fetch()) {
        echo json_encode([
            "status" => "error",
            "message" => "Email address is already registered."
        ]);
        exit();
    }

    // Create the user
    $stmt = $conn->prepare(
        "INSERT INTO users (username, email, password)
         VALUES (?, ?, ?)"
    );

    $stmt->execute([
        $username,
        $email,
        $hashed_password
    ]);

    echo json_encode([
        "status" => "success",
        "username" => $username,
        "message" => "Signup successful!"
    ]);

} catch (PDOException $e) {

    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}

?>
