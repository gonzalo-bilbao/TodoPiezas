<?php
/**
 * Script para insertar datos de prueba con contraseñas correctamente hasheadas.
 * Ejecutar UNA sola vez desde el navegador o terminal:
 *   http://localhost/todopiezas/seed.php
 * o
 *   php seed.php
 *
 * IMPORTANTE: Mover este archivo a htdocs/todopiezas/ antes de ejecutarlo.
 * Eliminarlo después de usarlo (no dejarlo en producción).
 */

$host = 'localhost';
$db   = 'todopiezas';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);

    // Limpiar datos existentes
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
    $pdo->exec('TRUNCATE TABLE piezas');
    $pdo->exec('TRUNCATE TABLE desguaces');
    $pdo->exec('SET FOREIGN_KEY_CHECKS = 1');

    $hash = password_hash('password123', PASSWORD_DEFAULT);

    // Insertar desguaces de prueba
    $stmt = $pdo->prepare(
        "INSERT INTO desguaces (nombre, direccion, telefono, email, password, lat, lng, horario)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );

    $desguaces = [
        ['Desguace El Motor',      'Calle Industrial 15, Polígono Norte, Madrid', '912345678', 'motor@desguace.com',  40.4736, -3.5699, 'Lun-Sáb 8:00-19:00'],
        ['Piezas García',          'Polígono Sur, Nave 7, Sevilla',               '954321098', 'garcia@piezas.com',   37.3613, -5.9659, 'Lun-Vie 9:00-18:00'],
        ['AutoRecambios Valencia',  'Avenida del Cid 45, Valencia',               '963456789', 'info@autorecambios.com', 39.4699, -0.3763, 'Lun-Vie 8:30-17:30'],
    ];

    foreach ($desguaces as $d) {
        $stmt->execute([$d[0], $d[1], $d[2], $d[3], $hash, $d[4], $d[5], $d[6]]);
    }

    // Insertar piezas de prueba
    $stmt2 = $pdo->prepare(
        "INSERT INTO piezas (nombre, descripcion, precio, estado, color, stock, categoria, marca, modelo, anyo, desguace_id)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    );

    $piezas = [
        ['Alternador',               'Alternador en buen estado, probado en banco',     85.00,  'Usado', 'Gris',        2, 'Eléctrico',    'Seat',       'Ibiza',   2015, 1],
        ['Puerta delantera izquierda','Sin golpes, pintura original conservada',         120.00, 'Usado', 'Rojo',        1, 'Carrocería',   'Seat',       'Ibiza',   2015, 1],
        ['Motor completo 1.6 TDI',   '98.000 km, buen estado general',                  950.00, 'Usado', 'Negro',       1, 'Motor',        'Volkswagen', 'Golf',    2018, 1],
        ['Paragolpes delantero',     'Pequeño arañazo en esquina inferior',             75.00,  'Usado', 'Blanco',      1, 'Carrocería',   'Renault',    'Megane',  2016, 2],
        ['Caja de cambios manual',   '5 velocidades, funciona perfectamente',           380.00, 'Usado', 'Gris',        1, 'Transmisión',  'Ford',       'Focus',   2014, 2],
        ['Faro delantero derecho',   'Nuevo de recambio, nunca montado',                145.00, 'Nuevo', 'Transparente',3, 'Eléctrico',    'BMW',        'Serie 3', 2019, 3],
        ['Amortiguador trasero',     'Par completo, desmontado hace 3 meses',           110.00, 'Usado', 'Negro',       2, 'Suspensión',   'Toyota',     'Corolla', 2017, 3],
        ['Salpicadero completo',     'Sin fisuras, con airbag y módulo de control',     220.00, 'Usado', 'Gris',        1, 'Interior',     'Peugeot',    '308',     2016, 1],
        ['Radiador',                 'Sin fugas, desmontado de vehículo siniestrado',   95.00,  'Usado', 'Plateado',    1, 'Motor',        'Hyundai',    'i30',     2017, 2],
        ['Disco de freno delantero', 'Par, con menos de 10.000 km de uso',              60.00,  'Usado', 'Gris',        3, 'Frenos',       'Opel',       'Astra',   2016, 3],
    ];

    foreach ($piezas as $p) {
        $stmt2->execute($p);
    }

    echo "<h2 style='color:green'>✅ Datos de prueba insertados correctamente</h2>";
    echo "<p><strong>Cuentas de acceso (todas con contraseña: <code>password123</code>):</strong></p>";
    echo "<ul>";
    foreach ($desguaces as $d) {
        echo "<li>{$d[0]} → <code>{$d[3]}</code></li>";
    }
    echo "</ul>";

} catch (Exception $e) {
    echo "<h2 style='color:red'>❌ Error: " . $e->getMessage() . "</h2>";
}
