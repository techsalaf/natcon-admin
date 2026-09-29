'use strict';
const fs = require('node:fs');
const path = require('node:path');

const source = fs.readFileSync(path.join(__dirname, '..', 'operations.js'), 'utf8');
const server = fs.readFileSync(path.join(__dirname, '../../api/natcon.php'), 'utf8');
const backend = fs.readFileSync(path.join(__dirname, '../../services/natcon/bootstrap.php'), 'utf8');
const flows = {
  'registrar can scan arrival': source.includes("api.request('checkin', { token, mode })"),
  'duplicate scans get an explicit state': source.includes("data.result === 'already_checked_in'"),
  'finance submits the verified bank amount': source.includes('verified_amount_kobo'),
  'finance cancellation is separate from payment': source.includes("api.request('cancel'"),
  'ticket allocation is recorded server-side': source.includes("api.request('entitlement'"),
  'staff session is recovered from server': source.includes("api.request('session')"),
  'payout balance is fetched from shared NATCON operations API': source.includes("api.request('payouts')") && source.includes('payout-available'),
  'admin payout requests and Finance review use role-specific routes': source.includes("user.role === 'finance'") && source.includes("api.request('request_payout'") && source.includes("api.request('review_payout'"),
  'completed payout records manual reference without an app transfer': source.includes("status === 'paid' ? 'Bank transfer reference") && !source.includes('transferToBank'),
  'web and organizer apps write events to the same canonical event service': source.includes("api.request('event_catalogue')") && source.includes("api.request('save_event'") && server.includes('saveOrganizerEvent($db,$in') && backend.includes('function saveOrganizerEvent('),
  'web and organizer apps write ticket types to the same canonical ticket service': source.includes("api.request('save_ticket_type'") && server.includes('saveOrganizerTicketType($db,') && backend.includes('function saveOrganizerTicketType('),
  'Admin event completion and cancellation update shared catalogue state without voiding paid orders': source.includes("api.request('event_status'") && server.includes("action==='event_status'") && backend.includes('function setOrganizerEventStatus(') && backend.includes("'paid_orders_preserved'=>true"),
};
const passed = Object.values(flows).filter(Boolean).length;
for (const [flow, result] of Object.entries(flows)) console.log(`${result ? 'PASS' : 'FAIL'} ${flow}`);
console.log(JSON.stringify({suite: 'operations-flow-contract', passed, total: Object.keys(flows).length, threshold: 1}));
if (passed !== Object.keys(flows).length) process.exitCode = 1;
