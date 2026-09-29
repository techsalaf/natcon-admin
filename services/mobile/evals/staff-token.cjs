const fs = require('node:fs');
const api = fs.readFileSync('lib/api.dart', 'utf8');
const route = fs.readFileSync('../../api/natcon.php', 'utf8');
const bootstrap = fs.readFileSync('../natcon/bootstrap.php', 'utf8');
const checks = [
  ['native staff login has a distinct action', route.includes("$action==='mobile_login'")],
  ['server stores a digest of a random bearer token', bootstrap.includes("hash('sha256',$token)") && bootstrap.includes('random_bytes(32)')],
  ['API resolves staff identity from the bearer digest', bootstrap.includes("t.principal_type='staff'") && bootstrap.includes('staffForToken')],
  ['shared Dart API sends the bearer token on requests', api.includes("headers['Authorization'] = 'Bearer $accessToken'")],
];
for (const [name, passed] of checks) console.log(`${passed ? 'PASS' : 'FAIL'} ${name}`);
if (checks.some(([, passed]) => !passed)) process.exitCode = 1;
