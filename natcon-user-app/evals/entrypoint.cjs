const fs = require('node:fs');
const source = fs.readFileSync('lib/main.dart', 'utf8');
const checks = [
  ['uses the original user app package', source.includes("package:magicmate_user/")],
  ['initializes the existing Firebase project', source.includes('DefaultFirebaseOptions.currentPlatform')],
  ['keeps the original route graph', source.includes('initialRoute: Routes.initial') && source.includes('getPages: getPages')],
  ['does not replace the app with the prototype', !source.includes('NatconApp(')],
];
for (const [name, passed] of checks) console.log(`${passed ? 'PASS' : 'FAIL'} ${name}`);
if (checks.some(([, passed]) => !passed)) process.exitCode = 1;
