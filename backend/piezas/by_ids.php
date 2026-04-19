<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$input = getJsonInput();
$ids = $input['ids'] ?? [];
if (!is_array($ids) || count($ids) === 0) {
    jsonResponse([]);
}

// Filtrar solo enteros
$ids = array_filter(array_map('intval', $ids), fn($v) => $v > 0);
if (count($ids) === 0) jsonResponse([]);

$placeholders = implode(',', array_fill(0, count($ids), '?'));

try {
    $db = getDB();
    $sql = "SELECT
                p.id, p.nombre, p.descripcion, p.precio, p.estado, p.imagen,
                p.color, p.stock, p.categoria, p.marca, p.modelo, p.anyo,
                p.desguace_id,
                d.nombre    AS desguace_nombre,
                d.telefono  AS desguace_telefono,
                d.whatsapp  AS desguace_whatsapp,
                d.lat       AS desguace_lat,
                d.lng       AS desguace_lng,
                d.direccion AS desguace_direccion
            FROM piezas p
            JOIN desguaces d ON p.desguace_id = d.id
            WHERE p.id IN ($placeholders)";
    $stmt = $db->prepare($sql);
    $stmt->execute($ids);
    jsonResponse($stmt->fetchAll());
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
