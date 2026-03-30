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

if ($id <= 0) jsonError('ID inválido');

try {
    $db = getDB();

    // Verificar que la pieza pertenece al desguace del admin autenticado
    $stmt = $db->prepare('SELECT desguace_id FROM piezas WHERE id = ?');
    $stmt->execute([$id]);
    $pieza = $stmt->fetch();

    if (!$pieza)                                            jsonError('Pieza no encontrada', 404);
    if ($pieza['desguace_id'] !== $auth['desguace_id'])    jsonError('Sin permisos', 403);

    $stmt = $db->prepare(
        "UPDATE piezas SET
             nombre      = ?,
             descripcion = ?,
             precio      = ?,
             estado      = ?,
             color       = ?,
             stock       = ?,
             categoria   = ?,
             marca       = ?,
             modelo      = ?,
             anyo        = ?
         WHERE id = ?"
    );

    $stmt->execute([
        $input['nombre'],
        $input['descripcion'] ?? '',
        $input['precio'],
        $input['estado'],
        $input['color'] ?? '',
        $input['stock'],
        $input['categoria'],
        $input['marca'],
        $input['modelo'],
        $input['anyo'],
        $id,
    ]);

    jsonResponse(['message' => 'Pieza actualizada']);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
