<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$auth = validateToken();
$desguaceId = (int)$auth['desguace_id'];

$input = getJsonInput();
$piezas = $input['piezas'] ?? [];
if (!is_array($piezas) || count($piezas) === 0) {
    jsonError('No se han recibido piezas');
}

$insertadas = 0;
$errores = [];

try {
    $db = getDB();
    $stmt = $db->prepare(
        'INSERT INTO piezas
          (desguace_id, nombre, descripcion, precio, estado, color, stock,
           categoria, marca, modelo, anyo)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );

    foreach ($piezas as $i => $p) {
        try {
            $stmt->execute([
                $desguaceId,
                $p['nombre']       ?? '',
                $p['descripcion']  ?? '',
                (float)($p['precio'] ?? 0),
                $p['estado']       ?? 'Usado',
                $p['color']        ?? null,
                (int)($p['stock']  ?? 1),
                $p['categoria']    ?? 'Otros',
                $p['marca']        ?? '',
                $p['modelo']       ?? '',
                (int)($p['anyo']   ?? 0),
            ]);
            $insertadas++;
        } catch (PDOException $e) {
            $errores[] = "Fila " . ($i + 1) . ": " . $e->getMessage();
        }
    }

    jsonResponse([
        'insertadas' => $insertadas,
        'errores'    => $errores,
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
