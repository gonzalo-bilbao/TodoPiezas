<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth = validateUserToken();
$userId = (int)$auth['user_id'];

$input = getJsonInput();
$piezaId = (int)($input['pieza_id'] ?? 0);
if ($piezaId <= 0) jsonError('Pieza inválida');

try {
    $db = getDB();
    $stmt = $db->prepare('DELETE FROM favoritos WHERE usuario_id = ? AND pieza_id = ?');
    $stmt->execute([$userId, $piezaId]);
    jsonResponse(['ok' => true]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
