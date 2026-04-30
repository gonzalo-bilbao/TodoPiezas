<?php
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    jsonError('No se recibió ninguna imagen');
}

$file = $_FILES['image'];
$ext  = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$allowed = ['jpg', 'jpeg', 'png', 'webp'];
if (!in_array($ext, $allowed, true)) {
    jsonError('Formato no permitido');
}

$dir = __DIR__ . '/../uploads/vehiculos/';
if (!is_dir($dir)) mkdir($dir, 0777, true);

$filename = 'vehiculo_' . uniqid() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
$dest = $dir . $filename;

if (!move_uploaded_file($file['tmp_name'], $dest)) {
    jsonError('No se pudo guardar el archivo');
}

jsonResponse(['foto' => 'uploads/vehiculos/' . $filename]);
