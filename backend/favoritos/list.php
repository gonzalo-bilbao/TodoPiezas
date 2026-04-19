<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$auth = validateUserToken();
$userId = (int)$auth['user_id'];

try {
    $db = getDB();
    $stmt = $db->prepare('SELECT pieza_id FROM favoritos WHERE usuario_id = ?');
    $stmt->execute([$userId]);
    $ids = array_map(fn($r) => (int)$r['pieza_id'], $stmt->fetchAll());
    jsonResponse($ids);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
