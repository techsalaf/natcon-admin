'use strict';
const fs=require('node:fs'),path=require('node:path');
const base=path.join(__dirname,'..');
const html=fs.readFileSync(path.join(base,'index.php'),'utf8'),js=fs.readFileSync(path.join(base,'assets/app.js'),'utf8'),ticket=fs.readFileSync(path.join(base,'assets/ticket.js'),'utf8'),service=fs.readFileSync(path.join(base,'../services/natcon/bootstrap.php'),'utf8'),styles=fs.readFileSync(path.join(base,'assets/style.css'),'utf8'),rewrite=fs.readFileSync(path.join(base,'../.htaccess'),'utf8');
const cases={
  'keyboard skip link':html.includes('class="skip"'),
  'privacy consent is explicit and required':html.includes('id="privacy-consent" type="checkbox" required')&&js.includes("$('privacy-consent').checked"),
  'group delegate removal':js.includes('fieldset.remove()'),
  'self-registration details follow the payer':js.includes("'payer-name', 'payer-email', 'payer-phone'")&&js.includes("value !== 'myself'"),
  'Delegate ID format is checked while typing':js.includes('updateDelegateIdFeedback(didInput)')&&js.includes('TAA/NC/REFORMATION'),
  'Delegate ID feedback does not claim TAA registry verification':js.includes('TAA staff will confirm the ID'),
  'server price authoritative':js.includes('order.amount_kobo'),
  'payment redirect host validated':js.includes("url.hostname === 'checkout.paystack.com'"),
  'unverified transfers wait for staff review':service.includes("'awaiting_review'")&&service.includes('confirmPayment'),
  'email recovery response is generic':html.includes('If a registration matches'),
  'mobile resume alias':js.includes("params.get('order')"),
  'ticket failure visible':ticket.includes("status.className='notice error'"),
  'QR failure blocks misleading print':ticket.includes("getElementById('print-ticket').disabled = true"),
  'no invented programme times':html.includes('Detailed session times will be announced'),
  'ticket print offered':ticket.includes('window.print()'),
  'delegate profile collects current registration fields':['email','course','institution','level','whatsapp','calling_line','state_origin','times_attended'].every(field=>js.includes(`data-field="${field}"`)),
  'graduate and NYSC statuses available':js.includes('Graduate')&&js.includes('NYSC</option>')&&js.includes('Postgraduate'),
  'published events and ticket types are selectable from canonical catalogue':js.includes("api('public_events',{},'GET')")&&js.includes("api('event',{event_id:eventId},'GET')")&&js.includes('event.ticket_types'),
  'web checkout submits selected event and ticket type ids':js.includes('data.event_id = String(event.event_id)')&&js.includes('data.ticket_type_id = selectedTicketTypeId'),
  'payment choices are plain-language conditional options':html.includes('How would you like to pay?')&&html.includes('name="payment_method" value="transfer_new" data-bank-transfer')&&js.includes("bankTransfer.value = 'transfer_prepaid'")&&js.includes('selectedPaymentMethod()'),
  'already-paid path requires delegate IDs and receipt':js.includes("i.required = hasPaid")&&js.includes("$('receipt-file').required = true")&&service.includes('$receiptRequired'),
  'bank receipt supports safe PDF and image content':html.includes('application/pdf')&&service.includes('finfo(FILEINFO_MIME_TYPE)')&&service.includes('2500000'),
  'removed accommodation and access questions are absent':!(/accommodation|accessibility/i.test(html)),
  'privacy route is explicit and opens in a new tab':html.includes('href="privacy.php" target="_blank"')&&rewrite.includes('conference/privacy/?$ conference/privacy.php'),
  'one conference footer contains contact and policy links':(html.match(/<footer\b/g)||[]).length===1&&html.includes('REGISTRATION SUPPORT')&&html.includes('Privacy policy'),
  'motion is local and reduced-motion aware':js.includes('IntersectionObserver')&&styles.includes('prefers-reduced-motion')&&!html.includes('unpkg.com/aos')
};
for(const [name,pass] of Object.entries(cases))console.log(`${pass?'PASS':'FAIL'} ${name}`);
const score=Object.values(cases).filter(Boolean).length;
console.log(JSON.stringify({suite:'delegate-flow-contract',score,total:Object.keys(cases).length,threshold:1}));
if(score!==Object.keys(cases).length)process.exitCode=1;
