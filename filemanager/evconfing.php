<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

try {
    $evmulti = new mysqli("localhost", "root", "", "natcon-admin");
    $evmulti->set_charset("utf8mb4");
} catch (Exception $e) {
    error_log($e->getMessage());
    //Should be a message a typical user could understand
}

$set = $evmulti->query("SELECT * FROM `tbl_setting`")->fetch_assoc();

// Ensure critical settings have defaults
if (!isset($set['timezone'])) {
    $set['timezone'] = 'UTC';
}
if (empty($set['weblogo']) || !is_file(__DIR__ . '/../' . ltrim($set['weblogo'], '/\\'))) {
    $websiteLogos = glob(__DIR__ . '/../images/website/*.{png,jpg,jpeg,webp}', GLOB_BRACE);
    $set['weblogo'] = $websiteLogos
        ? 'images/website/' . basename($websiteLogos[count($websiteLogos) - 1])
        : '';
}
if (empty($set['webname'])) {
    $set['webname'] = 'MagicMate';
}

date_default_timezone_set($set["timezone"]);

if (isset($_SESSION["stype"]) && $_SESSION["stype"] == "sowner") {
    
        $sdata = $evmulti
            ->query(
                "SELECT * FROM `tbl_sponsore` where email='" .
                    $_SESSION["evename"] .
                    "'"
            )
            ->fetch_assoc();
    
}

$maindata = $evmulti->query("SELECT * FROM `tbl_etom`")->fetch_assoc();
// Force disable remote activation script (clear any remote JS) and mark app as activated
if (!isset($maindata['data'])) {
    $maindata['data'] = '';
}
$maindata['data'] = '';
// Mark as activated to skip validation checks
$set['activated'] = 1;
$_SESSION['activated'] = 1;

// Determine base path for assets (supports sub-folder installs)
$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off' || $_SERVER['SERVER_PORT'] == 443) ? "https://" : "http://";
$domain = $_SERVER['HTTP_HOST'];
$base_url = $protocol . $domain . rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');

// For relative paths, use just the directory
$base = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/\\');
if ($base === '/' || $base === '\\' || $base === '.' || $base === '') {
    $base = '';
} else {
    $base = rtrim($base, '/\\');
} 
