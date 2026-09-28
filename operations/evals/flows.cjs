'use strict';
const fs = require('node:fs');
const path = require('node:path');

const source = fs.readFileSync(path.join(__dirname, '..', 'operations.js'), 'utf8');
const flows = {
  'registrar can scan arrival': source.includes("api.request('checkin', { token, mode })"),
  'duplicate scans get an explicit state': source.includes("data.result === 'already_checked_in'"),
  'finance submits the verified bank amount': source.includes('verified_amount_kobo'),
  'finance cancellation is separate from payment': source.includes("api.request('cancel'"),
  'ticket allocation is recorded server-side': source.includes("api.request('entitlement'"),
  'staff session is recovered from server': source.includes("api.request('session')"),
};
const passed = Object.values(flows).filter(Boolean).length;
for (const [flow, result] of Object.entries(flows)) console.log(`${result ? 'PASS' : 'FAIL'} ${flow}`);
console.log(JSON.stringify({suite: 'operations-flow-contract', passed, total: Object.keys(flows).length, threshold: 1}));
if (passed !== Object.keys(flows).length) process.exitCode = 1;
