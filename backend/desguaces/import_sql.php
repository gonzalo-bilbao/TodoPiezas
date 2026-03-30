<?php
require_once '../config/database.php';
require_once '../config/helpers.php';

setCorsHeaders();
$auth = validateToken();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Método no permitido', 405);
}

$input      = getJsonInput();
$sqlContent = $input['sql'] ?? '';
$desguaceId = $auth['desguace_id'];

if (empty($sqlContent)) {
    jsonError('Contenido SQL vacío');
}

// Dividir en sentencias individuales
$statements = array_filter(
    array_map('trim', explode(';', $sqlContent)),
    fn($s) => $s !== ''
);

$insertadas = 0;
$errores    = 0;
$db         = getDB();

// Palabras clave prohibidas (seguridad básica)
$forbidden = ['DROP', 'DELETE', 'TRUNCATE', 'ALTER', 'CREATE', 'UPDATE', 'GRANT', 'REVOKE'];

foreach ($statements as $stmt) {
    $upperStmt = strtoupper(ltrim($stmt));

    // Solo permitir INSERT
    if (!str_starts_with($upperStmt, 'INSERT')) {
        $errores++;
        continue;
    }

    // Rechazar si contiene palabras prohibidas fuera del INSERT
    $hasForbidden = false;
    foreach ($forbidden as $word) {
        if (str_contains($upperStmt, $word)) {
            $hasForbidden = true;
            break;
        }
    }
    if ($hasForbidden) {
        $errores++;
        continue;
    }

    try {
        // Forzar que la pieza pertenezca al desguace autenticado
        // Reemplaza cualquier desguace_id en el INSERT por el del usuario autenticado
        $stmt = preg_replace(
            '/desguace_id\s*=\s*\d+/i',
            "desguace_id = $desguaceId",
            $stmt
        );

        $db->exec($stmt);
        $insertadas++;
    } catch (PDOException $e) {
        $errores++;
    }
}

jsonResponse([
    'insertadas' => $insertadas,
    'errores'    => $errores,
    'mensaje'    => "Proceso completado: $insertadas piezas importadas, $errores errores.",
]);
