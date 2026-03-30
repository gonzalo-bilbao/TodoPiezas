<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$desguaceId = intval($_GET['desguace_id'] ?? 0);
if ($desguaceId <= 0) {
    jsonError('desguace_id requerido');
}

try {
    $db   = getDB();
    $stmt = $db->prepare(
        'SELECT id, nombre, estado, precio, stock, imagen, categoria, marca, modelo
         FROM piezas
         WHERE desguace_id = ? AND stock > 0
         ORDER BY nombre ASC'
    );
    $stmt->execute([$desguaceId]);
    jsonResponse($stmt->fetchAll());
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
