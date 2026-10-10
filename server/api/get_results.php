<?php
include 'db_connect.php';
$username = $_GET['username'] ?? '';

if (empty($username)) {
    echo json_encode(["status" => "error", "message" => "Username not provided."]);
    exit();
}

$stmt = $conn->prepare("SELECT id FROM users WHERE username = ?");
$stmt->execute([$username]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode(["status" => "error", "message" => "User not found."]);
    exit();
}

$userId = $user['id'];

$stmt = $conn->prepare("
    SELECT MIN(id) as id, game_type, game_date as created_at,
           COUNT(*) as total_questions,
           SUM(is_correct) as correct_answers
    FROM permanent_results
    WHERE user_id = ?
    GROUP BY user_id, game_type, game_date
    ORDER BY game_date DESC
");
$stmt->execute([$userId]);
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
echo json_encode(["status" => "success", "data" => $results]);
?>