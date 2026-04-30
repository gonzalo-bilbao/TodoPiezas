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
    $stmt = $db->prepare(
        'SELECT id, alias, marca, modelo, anyo, foto
         FROM vehiculos_usuario
         WHERE usuario_id = ?
         ORDER BY id ASC'
    );
    $stmt->execute([$userId]);
    $rows = $stmt->fetchAll();

    $out = array_map(fn($r) => [
        'id'     => (int)$r['id'],
        'alias'  => $r['alias'],
        'marca'  => $r['marca'],
        'modelo' => $r['modelo'],
        'anyo'   => $r['anyo'] !== null ? (int)$r['anyo'] : null,
        'foto'   => $r['foto'],
    ], $rows);

    jsonResponse($out);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
