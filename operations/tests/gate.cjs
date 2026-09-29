'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const html = fs.readFileSync(path.join(root, 'index.php'), 'utf8');
const js = fs.readFileSync(path.join(root, 'operations.js'), 'utf8');
const core = fs.readFileSync(path.join(root, 'core.js'), 'utf8');
const api = fs.readFileSync(path.join(root, '../api/natcon.php'), 'utf8');

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
  'staff register shows course institution status and NATCON history': js.includes('delegate.course') && js.includes('delegate.institution') && js.includes('delegate.level') && js.includes('delegate.times_attended'),
  'payout records share paid revenue, reservations, and available balance': html.includes('id="payout-revenue"') && html.includes('id="payout-reserved"') && html.includes('id="payout-available"') && js.includes("api.request('payouts')"),
  'only Admin can request and only Finance can review payouts': html.includes('id="payout-request-form"') && html.includes('data-admin') && js.includes("user.role === 'finance'") && js.includes("api.request('request_payout'") && js.includes("api.request('review_payout'"),
  'recording a payout as paid asks for manual transfer reference': js.includes("status === 'paid' ? 'Bank transfer reference") && js.includes('payoutReviewStatus === \'paid\' ? 8 : 4'),
  'event and ticket editors are visible only to Admin': html.includes('data-view="events" class="nav-item" data-admin hidden') && js.includes("view === 'events' && user?.role !== 'admin'"),
  'web event and ticket editors call Admin-protected shared-catalogue actions': api.includes("$action==='event_catalogue'") && api.includes("$action==='save_event'") && api.includes("$action==='save_ticket_type'") && js.includes("api.request('save_event'") && js.includes("api.request('save_ticket_type'"),
  'event editor exposes shared attendee catalogue fields and visibility': ['event-category','event-date','event-start','event-end','event-status','event-disclaimer','event-tags','event-videos'].every(id=>html.includes(`id="${id}"`)) && api.includes('saveOrganizerEvent($db,$in'),
};

for (const [name, passed] of Object.entries(cases)) {
  assert.equal(passed, true, name);
  console.log(`PASS ${name}`);
}
console.log(`PASS ${Object.keys(cases).length} operations gate assertions`);
