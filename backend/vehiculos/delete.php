<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth = validateUserToken();
$userId = (int)$auth['user_id'];
$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) jsonError('ID inválido');

try {
    $db = getDB();
    $stmt = $db->prepare('DELETE FROM vehiculos_usuario WHERE id = ? AND usuario_id = ?');
    $stmt->execute([$id, $userId]);
    jsonResponse(['ok' => true]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
