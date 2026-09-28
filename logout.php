<?php
session_start();
$_SESSION = [];
session_destroy();
$appBase = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
if ($appBase === '.') {
	$appBase = '';
}
header('Location: ' . ($appBase === '' ? '/' : $appBase . '/'), true, 303);
exit;
