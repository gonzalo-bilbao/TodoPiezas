<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Método no permitido', 405);
}

$auth = validateToken();
$desguaceId = (int)($_GET['desguace_id'] ?? $auth['desguace_id']);

try {
    $db = getDB();

    // Total piezas
    $stmt = $db->prepare('SELECT COUNT(*) AS total FROM piezas WHERE desguace_id = ?');
    $stmt->execute([$desguaceId]);
    $total = (int)$stmt->fetch()['total'];

    // Piezas sin stock
    $stmt = $db->prepare('SELECT COUNT(*) AS c FROM piezas WHERE desguace_id = ? AND stock = 0');
    $stmt->execute([$desguaceId]);
    $sinStock = (int)$stmt->fetch()['c'];

    // Stock total
    $stmt = $db->prepare('SELECT COALESCE(SUM(stock), 0) AS s FROM piezas WHERE desguace_id = ?');
    $stmt->execute([$desguaceId]);
    $stockTotal = (int)$stmt->fetch()['s'];

    // Valor total inventario
    $stmt = $db->prepare('SELECT COALESCE(SUM(precio * stock), 0) AS v FROM piezas WHERE desguace_id = ?');
    $stmt->execute([$desguaceId]);
    $valor = (float)$stmt->fetch()['v'];

    // Precio medio
    $stmt = $db->prepare('SELECT COALESCE(AVG(precio), 0) AS p FROM piezas WHERE desguace_id = ? AND stock > 0');
    $stmt->execute([$desguaceId]);
    $precioMedio = (float)$stmt->fetch()['p'];

    // Top categorías (las 3 con más piezas)
    $stmt = $db->prepare(
        'SELECT categoria, COUNT(*) AS n
         FROM piezas WHERE desguace_id = ?
         GROUP BY categoria ORDER BY n DESC LIMIT 3'
    );
    $stmt->execute([$desguaceId]);
    $top = $stmt->fetchAll();

    jsonResponse([
        'total_piezas'   => $total,
        'sin_stock'      => $sinStock,
        'stock_total'    => $stockTotal,
        'valor_inventario' => round($valor, 2),
        'precio_medio'   => round($precioMedio, 2),
        'top_categorias' => array_map(fn($r) => [
            'categoria' => $r['categoria'],
            'cantidad'  => (int)$r['n'],
        ], $top),
    ]);
} catch (PDOException $e) {
    jsonError('Error del servidor', 500);
}
