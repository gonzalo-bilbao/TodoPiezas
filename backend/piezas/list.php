<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$auth       = validateToken();
$desguaceId = isset($_GET['desguace_id']) ? (int) $_GET['desguace_id'] : 0;

// Un admin solo puede ver su propio inventario
if ($auth['desguace_id'] !== $desguaceId) {
    jsonError('Sin permisos', 403);
}

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
         WHERE p.desguace_id = ?
         ORDER BY p.created_at DESC"
    );
    $stmt->execute([$desguaceId]);

    jsonResponse($stmt->fetchAll());
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
