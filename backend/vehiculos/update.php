<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'PUT' && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth = validateUserToken();
$userId = (int)$auth['user_id'];
$id = (int)($_GET['id'] ?? 0);
if ($id <= 0) jsonError('ID inválido');

$input = getJsonInput();

try {
    $db = getDB();
    // Verificar propiedad
    $stmt = $db->prepare('SELECT usuario_id FROM vehiculos_usuario WHERE id = ?');
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) jsonError('Vehículo no encontrado', 404);
    if ((int)$row['usuario_id'] !== $userId) jsonError('Sin permisos', 403);

    // foto vacío = no cambiar; null explícito = borrar; valor = actualizar
    $stmt = $db->prepare(
        'UPDATE vehiculos_usuario SET
            alias  = ?,
            marca  = ?,
            modelo = ?,
            anyo   = ?,
            foto   = COALESCE(NULLIF(?, ""), foto)
         WHERE id = ?'
    );
    $stmt->execute([
        ($input['alias'] ?? '') === '' ? null : $input['alias'],
        $input['marca']  ?? '',
        $input['modelo'] ?? '',
        isset($input['anyo']) ? (int)$input['anyo'] : null,
        $input['foto']   ?? '',
        $id,
    ]);

    jsonResponse(['ok' => true]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
