<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$marca     = trim($_GET['marca']     ?? '');
$modelo    = trim($_GET['modelo']    ?? '');
$anyo      = isset($_GET['anyo'])    ? (int) $_GET['anyo'] : null;
$categoria = trim($_GET['categoria'] ?? '');
$color     = trim($_GET['color']     ?? '');
$estado    = trim($_GET['estado']    ?? '');

try {
    $db = getDB();

    $sql = "SELECT
                p.id,
                p.nombre,
                p.descripcion,
                p.precio,
                p.estado,
                p.imagen,
                p.color,
                p.stock,
                p.categoria,
                p.marca,
                p.modelo,
                p.anyo,
                p.desguace_id,
                d.nombre    AS desguace_nombre,
                d.telefono  AS desguace_telefono,
                d.whatsapp  AS desguace_whatsapp,
                d.lat       AS desguace_lat,
                d.lng       AS desguace_lng,
                d.direccion AS desguace_direccion
            FROM piezas p
            JOIN desguaces d ON p.desguace_id = d.id
            WHERE p.stock > 0";

    $params = [];

    if ($marca !== '')     { $sql .= ' AND p.marca = ?';           $params[] = $marca; }
    if ($modelo !== '')    { $sql .= ' AND p.modelo LIKE ?';       $params[] = "%$modelo%"; }
    if ($anyo !== null)    { $sql .= ' AND p.anyo = ?';            $params[] = $anyo; }
    if ($categoria !== '') { $sql .= ' AND p.categoria = ?';       $params[] = $categoria; }
    if ($color !== '')     { $sql .= ' AND p.color = ?';           $params[] = $color; }
    if ($estado !== '')    { $sql .= ' AND p.estado = ?';          $params[] = $estado; }

    $sql .= ' ORDER BY p.precio ASC LIMIT 100';

    $stmt = $db->prepare($sql);
    $stmt->execute($params);

    jsonResponse($stmt->fetchAll());
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
