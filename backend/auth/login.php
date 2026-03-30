<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$input    = getJsonInput();
$email    = trim($input['email'] ?? '');
$password = $input['password'] ?? '';

if (empty($email) || empty($password)) {
    jsonError('Email y contraseña requeridos');
}

try {
    $db   = getDB();
    $stmt = $db->prepare('SELECT * FROM desguaces WHERE email = ? LIMIT 1');
    $stmt->execute([$email]);
    $desguace = $stmt->fetch();

    if (!$desguace || !password_verify($password, $desguace['password'])) {
        jsonError('Credenciales incorrectas', 401);
    }

    jsonResponse([
        'token'           => generateToken($desguace['id']),
        'nombre'          => $desguace['nombre'],
        'desguace_id'     => $desguace['id'],
        'desguace_nombre' => $desguace['nombre'],
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
