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
$foto   = $input['foto'] ?? null;
if (is_string($foto) && trim($foto) === '') $foto = null;

if ($marca === '' || $modelo === '') {
    jsonError('Marca y modelo son obligatorios');
}

try {
    $db = getDB();
    $stmt = $db->prepare(
        'INSERT INTO vehiculos_usuario (usuario_id, alias, marca, modelo, anyo, foto)
         VALUES (?, ?, ?, ?, ?, ?)'
    );
    $stmt->execute([$userId, $alias === '' ? null : $alias, $marca, $modelo, $anyo, $foto]);

    jsonResponse([
        'id'     => (int)$db->lastInsertId(),
        'alias'  => $alias === '' ? null : $alias,
        'marca'  => $marca,
        'modelo' => $modelo,
        'anyo'   => $anyo,
        'foto'   => $foto,
    ], 201);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
