<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();
validateToken();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    jsonError('No se recibió ninguna imagen');
}

$file     = $_FILES['image'];
$ext      = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$allowed  = ['jpg', 'jpeg', 'png', 'webp'];

if (!in_array($ext, $allowed)) {
    jsonError('Formato no permitido. Usa JPG, PNG o WEBP');
}

$uploadDir = __DIR__ . '/../uploads/piezas/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$filename = uniqid('pieza_', true) . '.' . $ext;
$destPath = $uploadDir . $filename;

if (!move_uploaded_file($file['tmp_name'], $destPath)) {
    jsonError('Error al guardar la imagen', 500);
}

jsonResponse(['imagen' => 'uploads/piezas/' . $filename]);
