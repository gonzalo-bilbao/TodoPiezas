<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$id = isset($_GET['id']) ? (int) $_GET['id'] : 0;
if ($id <= 0) jsonError('ID inválido');

try {
    $db   = getDB();
    $stmt = $db->prepare(
        "SELECT
             p.*,
             d.nombre    AS desguace_nombre,
             d.telefono  AS desguace_telefono,
             d.lat       AS desguace_lat,
             d.lng       AS desguace_lng,
             d.direccion AS desguace_direccion
         FROM piezas p
         JOIN desguaces d ON p.desguace_id = d.id
         WHERE p.id = ?"
    );
    $stmt->execute([$id]);
    $pieza = $stmt->fetch();

    if (!$pieza) jsonError('Pieza no encontrada', 404);

    jsonResponse($pieza);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
