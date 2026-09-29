'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.join(__dirname,'..');
const html=fs.readFileSync(path.join(base,'index.php'),'utf8'),js=fs.readFileSync(path.join(base,'assets/app.js'),'utf8'),ticket=fs.readFileSync(path.join(base,'assets/ticket.js'),'utf8');
const cases={
  'keyboard skip link':html.includes('class="skip"'),
  'consent is required':html.includes('type="checkbox" required'),
  'group delegate removal':js.includes('fieldset.remove()'),
  'server price authoritative':js.includes('order.amount_kobo'),
  'payment redirect host validated':js.includes("url.hostname === 'checkout.paystack.com'"),
  'bank transfer does not imply paid':js.includes('finance team must confirm'),
  'email recovery generic':js.includes('If a registration matches'),
  'mobile resume alias':js.includes("params.get('order')"),
  'ticket failure visible':ticket.includes("status.className='notice error'"),
  'QR failure blocks misleading print':ticket.includes("getElementById('print-ticket').disabled = true"),
  'no invented programme times':html.includes('Detailed session times will be announced'),
  'ticket print offered':ticket.includes('window.print()'),
  'delegate profile collects requested fields':['email','course','institution','level','whatsapp','calling_line','state_origin','times_attended'].every(field=>js.includes(`data-field="${field}"`)),
  'graduate and NYSC statuses available':js.includes('Graduate')&&js.includes('NYSC Corp Member')&&js.includes('Masters'),
  'published events and ticket types are selectable from canonical catalogue':js.includes("api('public_events',{},'GET')")&&js.includes("api('event',{event_id:eventId},'GET')")&&js.includes('event.ticket_types'),
  'web checkout submits selected event and ticket type ids':js.includes('data.event_id = String(event.event_id)')&&js.includes('data.ticket_type_id = selectedTicketTypeId')
};
for(const [name,pass] of Object.entries(cases))console.log(`${pass?'PASS':'FAIL'} ${name}`);
const score=Object.values(cases).filter(Boolean).length;
console.log(JSON.stringify({suite:'delegate-flow-contract',score,total:Object.keys(cases).length,threshold:1}));
if(score!==Object.keys(cases).length)process.exitCode=1;
