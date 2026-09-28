<?php
// Debug page - shows DB and key table counts. Safe for troubleshooting.
include 'evconfing.php';
header('Content-Type: text/plain; charset=UTF-8');

echo "Debug: Database connection check\n";
// DB host info
if (isset($evmulti) && $evmulti instanceof mysqli) {
    echo "MySQL host info: " . $evmulti->host_info . "\n";
    $db = $evmulti->query("SELECT DATABASE()")->fetch_row()[0];
    echo "Database in use: " . ($db ?: 'unknown') . "\n";
} else {
    echo "No mysqli connection object found.\n";
    exit;
}

$tables = [
    'tbl_sponsore','tbl_event','tbl_category','tbl_ticket','tbl_page','tbl_faq','payout_setting','tbl_payment_list','tbl_user'
];
foreach ($tables as $t) {
    $res = null;
    try {
        $r = $evmulti->query("SELECT COUNT(*) AS c FROM `" . $evmulti->real_escape_string($t) . "`");
        if ($r) {
            $row = $r->fetch_assoc();
            $res = isset($row['c']) ? $row['c'] : 'N/A';
        } else {
            $res = 'table not found or query error';
        }
    } catch (Exception $e) {
        $res = 'error';
    }
    echo sprintf("%s: %s\n", $t, $res);
}

// Show latest ids for key tables
$keys = ['tbl_sponsore','tbl_event','tbl_category'];
foreach ($keys as $k) {
    $r = $evmulti->query("SELECT id FROM `" . $evmulti->real_escape_string($k) . "` ORDER BY id DESC LIMIT 1");
    if ($r && $r->num_rows) {
        $row = $r->fetch_assoc();
        echo sprintf("Last id in %s: %s\n", $k, $row['id']);
    } else {
        echo sprintf("Last id in %s: none\n", $k);
    }
}

// Print current session user (if any)
echo "Session user (evename): " . (isset($_SESSION['evename']) ? $_SESSION['evename'] : 'none') . "\n";
echo "Session stype: " . (isset($_SESSION['stype']) ? $_SESSION['stype'] : 'none') . "\n";

echo "\nEnd of debug output.\n";
