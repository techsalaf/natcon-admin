<?php
declare(strict_types=1);

/**
 * Creates .env.natcon from the legacy app's literal mysqli connection.
 * Run only through SSH: php scripts/bootstrap-host-config.php https://host
 * It never prints database credentials and refuses web execution.
 */
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$baseUrl = rtrim((string) ($argv[1] ?? ''), '/');
if (!filter_var($baseUrl, FILTER_VALIDATE_URL) || !str_starts_with($baseUrl, 'https://')) {
    fwrite(STDERR, "Provide the HTTPS public base URL.\n");
    exit(1);
}

$legacyConfig = dirname(__DIR__) . '/filemanager/evconfing.php';
$source = @file_get_contents($legacyConfig);
$pattern = '/new\s+mysqli\s*\(\s*([\'\"])([^\'\"]*)\1\s*,\s*([\'\"])([^\'\"]*)\3\s*,\s*([\'\"])([^\'\"]*)\5\s*,\s*([\'\"])([^\'\"]*)\7\s*\)/';
if (!is_string($source) || !preg_match($pattern, $source, $match)) {
    fwrite(STDERR, "Could not read a literal legacy MySQL connection. Create .env.natcon manually from .env.natcon.example.\n");
    exit(1);
}

[$host, $user, $password, $database] = [$match[2], $match[4], $match[6], $match[8]];
if ($host === '' || $user === '' || $database === '') {
    fwrite(STDERR, "Legacy database connection is incomplete.\n");
    exit(1);
}
$dsn = 'mysql:host=' . $host . ';dbname=' . $database . ';charset=utf8mb4';
$contents = "NATCON_DSN={$dsn}\nNATCON_DB_USER={$user}\nNATCON_DB_PASSWORD={$password}\nNATCON_BASE_URL={$baseUrl}\nPAYSTACK_SECRET_KEY=\nNATCON_MAIL_FROM=\nNATCON_CAPACITY=0\nNATCON_REGISTRATION_CLOSES=2026-10-04 23:59:59\n";
$target = dirname(__DIR__) . '/.env.natcon';
if (file_put_contents($target, $contents, LOCK_EX) === false || !chmod($target, 0600)) {
    fwrite(STDERR, "Could not write protected NATCON configuration.\n");
    exit(1);
}
echo "Created protected NATCON configuration using the existing database connection.\n";
