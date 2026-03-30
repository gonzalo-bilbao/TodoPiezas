<?php

// ── Configuración de base de datos ────────────────────────────
define('DB_HOST', 'localhost');
define('DB_NAME', 'todopiezas');
define('DB_USER', 'root');
define('DB_PASS', '');          // Cambia en producción

// Clave secreta para firmar tokens (¡cambiar en producción!)
define('SECRET_KEY', 'todopiezas_secret_key_2024_cambiar');

function getDB(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
    return $pdo;
}
