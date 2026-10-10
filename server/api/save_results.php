<?php
include 'db_connect.php';
$username = $_POST['username'] ?? '';
$resultsData = $_POST['results_data'] ?? '';
$gameType = $_POST['game_type'] ?? '';

if (empty($username) || empty($resultsData) || empty($gameType)) {
    echo json_encode(["status" => "error", "message" => "Invalid data provided."]);
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
$questions = json_decode($resultsData, true);

if (!$questions || !is_array($questions)) {
    echo json_encode(["status" => "error", "message" => "Invalid results data."]);
    exit();
}

// Use a single timestamp for all rows in this save
// so they are grouped as one session
$gameDate = date('Y-m-d H:i:s');

$stmt = $conn->prepare("INSERT INTO permanent_results 
    (user_id, player, game_type, question_text, user_answer, correct_answer, is_correct, game_date) 
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

foreach ($questions as $q) {
    // Get player from the result, default to 'p1'
    $player = $q['player'] ?? 'p1';
    $stmt->execute([
        $userId,
        $player,
        $gameType,
        $q['question'],
        $q['providedAnswer'],
        $q['correctAnswer'],
        $q['wasCorrect'] ? 1 : 0,
        $gameDate   // Same timestamp for all rows = one session
    ]);
}

echo json_encode(["status" => "success", "message" => "Results saved successfully."]);
?>
