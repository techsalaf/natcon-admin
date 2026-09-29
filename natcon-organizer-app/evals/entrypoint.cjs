const fs = require('node:fs');
const source = fs.readFileSync('lib/main.dart', 'utf8');
const checks = [
  ['uses the original organizer app package', source.includes("package:magicmate_organizer/")],
  ['initializes the existing Firebase project', source.includes('DefaultFirebaseOptions.currentPlatform')],
  ['keeps the original organizer navigation', source.includes('GetMaterialApp(') && source.includes('home: onbording()')],
  ['does not replace the app with the prototype', !source.includes('NatconApp(')],
];
for (const [name, passed] of checks) console.log(`${passed ? 'PASS' : 'FAIL'} ${name}`);
if (checks.some(([, passed]) => !passed)) process.exitCode = 1;
