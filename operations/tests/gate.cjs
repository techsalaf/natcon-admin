'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.php'), 'utf8');
const js = fs.readFileSync(path.join(root, 'operations.js'), 'utf8');
const core = fs.readFileSync(path.join(root, 'core.js'), 'utf8');

const cases = {
  'staff page is not indexed': html.includes('name="robots" content="noindex,nofollow"'),
  'staff page has a content-security policy': html.includes('Content-Security-Policy'),
  'finance approval requires a statement amount': html.includes('id="verified-amount"') && js.includes('verified_amount_kobo'),
  'finance approval requires explicit confirmation': html.includes('id="credit-confirmed"') && js.includes("$('credit-confirmed').checked"),
  'cancellation cannot send money': html.includes('This does not send money'),
  'staff mutations send csrf': core.includes("X-CSRF-Token") && core.includes('this.csrf'),
  'scanner supports manual entry': html.includes('id="ticket-code"') && js.includes("api.request('checkin'"),
  'scanner handles already-checked-in state': js.includes('already_checked_in'),
  'camera is stopped when hidden': js.includes("document.addEventListener('visibilitychange'") && js.includes('stopCamera'),
  'untrusted delegate strings use DOM text nodes': js.includes("detailCell(delegate.name") && js.includes("document.createElement(tag)"),
};

for (const [name, passed] of Object.entries(cases)) {
  assert.equal(passed, true, name);
  console.log(`PASS ${name}`);
}
console.log(`PASS ${Object.keys(cases).length} operations gate assertions`);
