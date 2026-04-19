<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$auth = validateToken();
$id   = isset($_GET['id']) ? (int) $_GET['id'] : 0;

if ($id <= 0 || $id !== $auth['desguace_id']) {
    jsonError('Sin permisos', 403);
}

try {
    $db   = getDB();
    $stmt = $db->prepare(
        'SELECT id, nombre, direccion, telefono, whatsapp, email, lat, lng, horario FROM desguaces WHERE id = ?'
    );
    $stmt->execute([$id]);
    $desguace = $stmt->fetch();

    if (!$desguace) jsonError('Desguace no encontrado', 404);

    jsonResponse($desguace);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
