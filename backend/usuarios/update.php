<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth = validateUserToken();
$userId = (int)$auth['user_id'];

$input = getJsonInput();

try {
    $db = getDB();
    $stmt = $db->prepare(
        'UPDATE usuarios_particulares SET
            nombre = COALESCE(NULLIF(?, ""), nombre),
            foto   = COALESCE(NULLIF(?, ""), foto)
         WHERE id = ?'
    );
    $stmt->execute([
        $input['nombre'] ?? '',
        $input['foto']   ?? '',
        $userId,
    ]);

    $stmt = $db->prepare(
        'SELECT id, email, nombre, foto FROM usuarios_particulares WHERE id = ?'
    );
    $stmt->execute([$userId]);
    $u = $stmt->fetch();

    jsonResponse([
        'id'     => (int)$u['id'],
        'email'  => $u['email'],
        'nombre' => $u['nombre'],
        'foto'   => $u['foto'],
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
