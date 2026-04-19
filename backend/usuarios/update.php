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
            marca  = ?,
            modelo = ?,
            anyo   = ?,
            foto   = COALESCE(NULLIF(?, ""), foto)
         WHERE id = ?'
    );
    $stmt->execute([
        $input['nombre'] ?? '',
        $input['marca']  ?? null,
        $input['modelo'] ?? null,
        $input['anyo']   ?? null,
        $input['foto']   ?? '',
        $userId,
    ]);

    $stmt = $db->prepare(
        'SELECT id, email, nombre, foto, marca, modelo, anyo
         FROM usuarios_particulares WHERE id = ?'
    );
    $stmt->execute([$userId]);
    $u = $stmt->fetch();

    jsonResponse([
        'id'     => (int)$u['id'],
        'email'  => $u['email'],
        'nombre' => $u['nombre'],
        'foto'   => $u['foto'],
        'marca'  => $u['marca'],
        'modelo' => $u['modelo'],
        'anyo'   => $u['anyo'] !== null ? (int)$u['anyo'] : null,
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
