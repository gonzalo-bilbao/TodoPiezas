<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$input = getJsonInput();

// Validar campos requeridos
$required = ['nombre', 'direccion', 'telefono', 'email', 'password', 'lat', 'lng'];
foreach ($required as $field) {
    if (empty($input[$field])) {
        jsonError("Campo requerido: $field");
    }
}

// Validar formato email
if (!filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
    jsonError('Email no válido');
}

// Validar longitud contraseña
if (strlen($input['password']) < 6) {
    jsonError('La contraseña debe tener al menos 6 caracteres');
}

try {
    $db = getDB();

    // Comprobar si el email ya existe
    $stmt = $db->prepare('SELECT id FROM desguaces WHERE email = ?');
    $stmt->execute([$input['email']]);
    if ($stmt->fetch()) {
        jsonError('Ya existe un desguace con ese email', 409);
    }

    // Insertar nuevo desguace
    $stmt = $db->prepare(
        "INSERT INTO desguaces (nombre, direccion, telefono, email, password, lat, lng, horario)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );

    $stmt->execute([
        $input['nombre'],
        $input['direccion'],
        $input['telefono'],
        $input['email'],
        password_hash($input['password'], PASSWORD_DEFAULT),
        $input['lat'],
        $input['lng'],
        $input['horario'] ?? 'Lun-Vie 9:00-18:00',
    ]);

    $newId = (int) $db->lastInsertId();

    jsonResponse([
        'token'           => generateToken($newId),
        'nombre'          => $input['nombre'],
        'desguace_id'     => $newId,
        'desguace_nombre' => $input['nombre'],
        'message'         => 'Desguace registrado correctamente',
    ], 201);

} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
