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

if ($email === '' || $password === '') {
    jsonError('Email y contraseña requeridos');
}

try {
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT id, email, password, nombre, foto, marca, modelo, anyo
         FROM usuarios_particulares WHERE email = ?'
    );
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password'])) {
        jsonError('Email o contraseña incorrectos', 401);
    }

    $token = generateUserToken((int)$user['id']);

    jsonResponse([
        'token' => $token,
        'usuario' => [
            'id'     => (int)$user['id'],
            'email'  => $user['email'],
            'nombre' => $user['nombre'],
            'foto'   => $user['foto'],
            'marca'  => $user['marca'],
            'modelo' => $user['modelo'],
            'anyo'   => $user['anyo'] !== null ? (int)$user['anyo'] : null,
        ],
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
