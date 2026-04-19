<?php

// ── CORS y cabeceras ───────────────────────────────────────────
function setCorsHeaders(): void
{
    header('Access-Control-Allow-Origin: *');
    header('Content-Type: application/json; charset=UTF-8');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

// ── Respuestas JSON ────────────────────────────────────────────
function jsonResponse(mixed $data, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit();
}

function jsonError(string $message, int $status = 400): void
{
    http_response_code($status);
    echo json_encode(['message' => $message], JSON_UNESCAPED_UNICODE);
    exit();
}

// ── Tokens (JWT simplificado, sin librería externa) ────────────
function generateToken(int $desguaceId): string
{
    $payload   = base64_encode(json_encode([
        'desguace_id' => $desguaceId,
        'exp'         => time() + 86400 * 7,  // 7 días
    ]));
    $signature = hash_hmac('sha256', $payload, SECRET_KEY);
    return "$payload.$signature";
}

function validateToken(): array
{
    $headers = getallheaders();
    $auth    = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (!str_starts_with($auth, 'Bearer ')) {
        jsonError('Token requerido', 401);
    }

    $token = substr($auth, 7);
    $parts = explode('.', $token);

    if (count($parts) !== 2) {
        jsonError('Token inválido', 401);
    }

    [$payload, $signature] = $parts;

    if (!hash_equals(hash_hmac('sha256', $payload, SECRET_KEY), $signature)) {
        jsonError('Token inválido', 401);
    }

    $data = json_decode(base64_decode($payload), true);

    if (!$data || $data['exp'] < time()) {
        jsonError('Token expirado', 401);
    }

    return $data;
}

// ── Input JSON del body ────────────────────────────────────────
function getJsonInput(): array
{
    $raw = file_get_contents('php://input');
    return json_decode($raw, true) ?? [];
}

// ── Tokens usuarios particulares ───────────────────────────────
function generateUserToken(int $userId): string
{
    $payload   = base64_encode(json_encode([
        'user_id' => $userId,
        'type'    => 'user',
        'exp'     => time() + 86400 * 30, // 30 días
    ]));
    $signature = hash_hmac('sha256', $payload, SECRET_KEY);
    return "$payload.$signature";
}

function validateUserToken(): array
{
    $headers = getallheaders();
    $auth    = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (!str_starts_with($auth, 'Bearer ')) {
        jsonError('Token requerido', 401);
    }

    $token = substr($auth, 7);
    $parts = explode('.', $token);

    if (count($parts) !== 2) {
        jsonError('Token inválido', 401);
    }

    [$payload, $signature] = $parts;

    if (!hash_equals(hash_hmac('sha256', $payload, SECRET_KEY), $signature)) {
        jsonError('Token inválido', 401);
    }

    $data = json_decode(base64_decode($payload), true);

    if (!$data || ($data['type'] ?? '') !== 'user' || $data['exp'] < time()) {
        jsonError('Token expirado o inválido', 401);
    }

    return $data;
}
