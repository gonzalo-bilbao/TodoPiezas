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
$alias  = trim($input['alias']  ?? '');
$marca  = trim($input['marca']  ?? '');
$modelo = trim($input['modelo'] ?? '');
$anyo   = isset($input['anyo']) ? (int)$input['anyo'] : null;

if ($marca === '' || $modelo === '') {
    jsonError('Marca y modelo son obligatorios');
}

try {
    $db = getDB();
    $stmt = $db->prepare(
        'INSERT INTO vehiculos_usuario (usuario_id, alias, marca, modelo, anyo)
         VALUES (?, ?, ?, ?, ?)'
    );
    $stmt->execute([$userId, $alias === '' ? null : $alias, $marca, $modelo, $anyo]);

    jsonResponse([
        'id'     => (int)$db->lastInsertId(),
        'alias'  => $alias === '' ? null : $alias,
        'marca'  => $marca,
        'modelo' => $modelo,
        'anyo'   => $anyo,
    ], 201);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
