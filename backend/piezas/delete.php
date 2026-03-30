<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    jsonError('Método no permitido', 405);
}

$auth = validateToken();
$id   = isset($_GET['id']) ? (int) $_GET['id'] : 0;

if ($id <= 0) jsonError('ID inválido');

try {
    $db   = getDB();
    $stmt = $db->prepare('SELECT desguace_id FROM piezas WHERE id = ?');
    $stmt->execute([$id]);
    $pieza = $stmt->fetch();

    if (!$pieza)                                            jsonError('Pieza no encontrada', 404);
    if ($pieza['desguace_id'] !== $auth['desguace_id'])    jsonError('Sin permisos', 403);

    $db->prepare('DELETE FROM piezas WHERE id = ?')->execute([$id]);

    jsonResponse(['message' => 'Pieza eliminada']);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
