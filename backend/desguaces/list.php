<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

try {
    $db   = getDB();
    $stmt = $db->query(
        'SELECT id, nombre, direccion, telefono, whatsapp, email, lat, lng, horario FROM desguaces'
    );

    jsonResponse($stmt->fetchAll());
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
