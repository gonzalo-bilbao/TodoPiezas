<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    jsonError('Método no permitido', 405);
}

$auth  = validateToken();
$id    = isset($_GET['id']) ? (int) $_GET['id'] : 0;
$input = getJsonInput();

if ($id <= 0 || $id !== $auth['desguace_id']) {
    jsonError('Sin permisos', 403);
}

try {
    $db   = getDB();
    $stmt = $db->prepare(
        "UPDATE desguaces SET
             nombre    = ?,
             direccion = ?,
             telefono  = ?,
             horario   = ?,
             lat       = ?,
             lng       = ?
         WHERE id = ?"
    );

    $stmt->execute([
        $input['nombre'],
        $input['direccion'],
        $input['telefono'],
        $input['horario'] ?? '',
        $input['lat'],
        $input['lng'],
        $id,
    ]);

    jsonResponse(['message' => 'Perfil actualizado']);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
