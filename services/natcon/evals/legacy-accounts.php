<?php
declare(strict_types=1);
$test=shell_exec(escapeshellarg(PHP_BINARY).' '.escapeshellarg(dirname(__DIR__).'/tests/legacy-accounts.php').' 2>&1');
$passed=is_string($test)&&str_contains($test,'PASS reversible legacy account migration:');
echo json_encode(['suite'=>'legacy-account-migration','passed'=>$passed?1:0,'total'=>1,'score'=>$passed?1:0,'threshold'=>1,'evidence'=>trim((string)$test)],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
if(!$passed)exit(1);
