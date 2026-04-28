<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$input = getJsonInput();
$email    = trim($input['email']    ?? '');
$password = $input['password'] ?? '';
$nombre   = trim($input['nombre']   ?? '');

if ($email === '' || $password === '' || $nombre === '') {
    jsonError('Faltan campos obligatorios');
}
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    jsonError('Email no válido');
}
if (strlen($password) < 4) {
    jsonError('La contraseña debe tener al menos 4 caracteres');
}

try {
    $db = getDB();

    $stmt = $db->prepare('SELECT id FROM usuarios_particulares WHERE email = ?');
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        jsonError('Ya existe una cuenta con ese email', 409);
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $db->prepare(
        'INSERT INTO usuarios_particulares (email, password, nombre)
         VALUES (?, ?, ?)'
    );
    $stmt->execute([$email, $hash, $nombre]);

    $id = (int)$db->lastInsertId();
    $token = generateUserToken($id);

    jsonResponse([
        'token' => $token,
        'usuario' => [
            'id'     => $id,
            'email'  => $email,
            'nombre' => $nombre,
            'foto'   => null,
        ],
    ], 201);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
