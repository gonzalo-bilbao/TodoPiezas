<?php
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

if (!isset($_FILES['image'])) {
    jsonError('No se recibió ninguna imagen');
}

$file = $_FILES['image'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    jsonError('Error al subir el archivo');
}

$allowed = ['jpg', 'jpeg', 'png', 'webp'];
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
if (!in_array($ext, $allowed, true)) {
    jsonError('Formato no permitido');
}

$dir = __DIR__ . '/../uploads/usuarios/';
if (!is_dir($dir)) {
    mkdir($dir, 0777, true);
}

$filename = 'user_' . uniqid() . '.' . $ext;
$destino = $dir . $filename;

if (!move_uploaded_file($file['tmp_name'], $destino)) {
    jsonError('No se pudo guardar el archivo');
}

jsonResponse(['foto' => 'uploads/usuarios/' . $filename]);
