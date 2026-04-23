<?php
// Proxy de imágenes con cabecera CORS
// Uso: image.php?path=uploads/piezas/pieza_xxx.jpg

$path = $_GET['path'] ?? '';

// Seguridad básica: solo permitir uploads/piezas/ y uploads/usuarios/
if (!preg_match('#^uploads/(piezas|usuarios)/[A-Za-z0-9_\.-]+\.(jpg|jpeg|png|webp|gif)$#i', $path)) {
    http_response_code(400);
    exit;
}

$full = __DIR__ . '/../' . $path;
if (!file_exists($full)) {
    http_response_code(404);
    exit;
}

$mime = function_exists('mime_content_type')
    ? mime_content_type($full)
    : 'image/' . strtolower(pathinfo($full, PATHINFO_EXTENSION));

header('Access-Control-Allow-Origin: *');
header('Content-Type: ' . $mime);
header('Cache-Control: public, max-age=3600');
header('Content-Length: ' . filesize($full));
readfile($full);
