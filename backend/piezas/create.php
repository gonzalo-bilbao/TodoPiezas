<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth  = validateToken();
$input = getJsonInput();

// Validar campos requeridos
$required = ['nombre', 'precio', 'marca', 'modelo', 'anyo', 'categoria', 'estado', 'stock', 'desguace_id'];
foreach ($required as $field) {
    if (!isset($input[$field]) || (string) $input[$field] === '') {
        jsonError("Campo requerido: $field");
    }
}

// El admin solo puede añadir piezas a su propio desguace
if ($auth['desguace_id'] !== (int) $input['desguace_id']) {
    jsonError('Sin permisos', 403);
}

try {
    $db   = getDB();
    $stmt = $db->prepare(
        "INSERT INTO piezas
             (nombre, descripcion, precio, estado, imagen, color, stock, categoria, marca, modelo, anyo, desguace_id)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );

    $stmt->execute([
        $input['nombre'],
        $input['descripcion'] ?? '',
        $input['precio'],
        $input['estado'],
        $input['imagen'] ?? null,
        $input['color'] ?? '',
        $input['stock'],
        $input['categoria'],
        $input['marca'],
        $input['modelo'],
        $input['anyo'],
        $input['desguace_id'],
    ]);

    jsonResponse(['id' => (int) $db->lastInsertId(), 'message' => 'Pieza creada'], 201);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
