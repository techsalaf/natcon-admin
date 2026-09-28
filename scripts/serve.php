<?php
declare(strict_types=1);

// A development router with the same public boundary as the Apache deployment.
// Usage: php -S 127.0.0.1:8088 scripts/serve.php
$root = dirname(__DIR__);
$path = rawurldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/');
if (str_contains($path, '..') || str_contains($path, '\\') || str_contains($path, "\0")) {
    http_response_code(400);
    exit('Invalid path');
}
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: no-referrer');
header('X-Frame-Options: DENY');
if ($path === '/') {
    header('Location: /conference/', true, 302);
    exit;
}
$allowed = preg_match('~^/(?:conference|operations)/(?:[a-zA-Z0-9_/-]+\.(?:php|css|js|svg|png|ico|webmanifest)|)$~D', $path)
    || $path === '/api/natcon.php';
if (!$allowed || preg_match('~(?:test|eval|node_modules|/\.)~i', $path)) {
    http_response_code(404);
    exit('Not found');
}
$file = $root . $path;
if (is_dir($file)) {
    $file .= '/index.php';
}
if (!is_file($file)) {
    http_response_code(404);
    exit('Not found');
}
if (str_ends_with($file, '.php')) {
    require $file;
    return true;
}
return false;
