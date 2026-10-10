<?php
include 'db_connect.php';
$resultId = $_GET['id'] ?? '';

if (empty($resultId)) {
    echo json_encode(["status" => "error", "message" => "Result ID not provided."]);
    exit();
}

$stmt = $conn->prepare("SELECT game_date, user_id, game_type 
                        FROM permanent_results WHERE id = ?");
$stmt->execute([$resultId]);
$ref = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$ref) {
    echo json_encode(["status" => "error", "message" => "Result not found."]);
    exit();
}

// Fetch ONLY this user's questions from this session
// user_id + game_date together uniquely identify one player's session
$stmt = $conn->prepare("
    SELECT question_text as question,
           user_answer as providedAnswer,
           correct_answer as correctAnswer,
           is_correct as wasCorrect,
           player
    FROM permanent_results
    WHERE user_id = ? AND game_date = ?
    ORDER BY id ASC
");
$stmt->execute([$ref['user_id'], $ref['game_date']]);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

foreach ($rows as &$row) {
    $row['wasCorrect'] = (bool)$row['wasCorrect'];
}

echo json_encode(["status" => "success", "data" => $rows]);
?>