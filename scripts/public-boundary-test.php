<?php
declare(strict_types=1);

// Run against a development server or staging host; no mutations are performed.
$base = rtrim($argv[1] ?? 'http://127.0.0.1:8088', '/');
$paths = ['/db/MagicMate.sql', '/filemanager/evconfing.php', '/user_api/book_ticket.php', '/old/index.php',
    '/orag_api/qr_ticket_verify.php', '/.git/config', '/.env', '/services/natcon/Config.php',
    '/AGENTS.md', '/assets/js/datatable/datatable-extension/directory/del_direct.php'];
$failed = 0;
foreach ($paths as $path) {
    $ch = curl_init($base . $path);
    curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_TIMEOUT => 5]);
    curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    $ok = in_array($status, [403, 404, 410], true);
    echo ($ok ? 'PASS' : 'FAIL') . " $path ($status)\n";
    if (!$ok) $failed++;
}
exit($failed > 0 ? 1 : 0);
