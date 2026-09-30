'use strict';
const assert = require('node:assert/strict');
const {spawn, spawnSync} = require('node:child_process');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const net = require('node:net');

const repo = path.resolve(__dirname, '../..');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'natcon-multi-event-'));
const dsn = `sqlite:${path.join(temp, 'natcon.sqlite').replaceAll('\\', '/')}`;
const env = {...process.env, NATCON_DSN: dsn, NATCON_DB_USER: '', NATCON_DB_PASSWORD: '', NATCON_BASE_URL: 'http://127.0.0.1'};
const phpQuote = value => `'${value.replaceAll('\\', '\\\\').replaceAll("'", "\\'")}'`;
const bootstrap = path.join(repo, 'services/natcon/bootstrap.php');
const fixture = `require ${phpQuote(bootstrap)}; $db=new PDO(${phpQuote(dsn)}); Natcon\\migrate($db); $category=(string)$db->query("SELECT id FROM natcon_categories WHERE status='active' ORDER BY id LIMIT 1")->fetchColumn(); $event=Natcon\\saveOrganizerEvent($db,['title'=>'HTTP Shared Event','pname'=>'Abuja Venue','cdesc'=>'HTTP flow','sdate'=>'2026-11-02','stime'=>'09:00','etime'=>'17:00','cat_id'=>$category,'status'=>'published']); Natcon\\saveOrganizerTicketType($db,['event_id'=>$event['event_id'],'etype'=>'HTTP Admission','price'=>'3210.50','tlimit'=>'5','status'=>'1']); $db->prepare('INSERT INTO natcon_staff(name,email,password_hash,role) VALUES(?,?,?,?)')->execute(['E2E Admin','admin@example.test',password_hash('e2e-test-password',PASSWORD_DEFAULT),'admin']); echo $event['event_id'];`;

async function freePort() {
  const server = net.createServer();
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  const port = server.address().port;
  await new Promise(resolve => server.close(resolve));
  return port;
}
async function ready(url, child) {
  for (let attempt=0; attempt<100; attempt++) {
    if (child.exitCode !== null) throw new Error('PHP test server exited before becoming ready.');
    try { await fetch(url); return; } catch (_) { await new Promise(resolve => setTimeout(resolve, 50)); }
  }
  throw new Error('PHP test server did not become ready.');
}

(async () => {
  try {
    const seeded = spawnSync('php', ['-r', fixture], {cwd: repo, env, encoding: 'utf8'});
    assert.equal(seeded.status, 0, seeded.stderr);
    const eventId = seeded.stdout.trim();
    assert.match(eventId, /^[1-9]\d*$/);
    const port = await freePort();
    const server = spawn('php', ['-S', `127.0.0.1:${port}`, '-t', repo], {cwd: repo, env, stdio: 'ignore'});
    try {
      const base = `http://127.0.0.1:${port}`;
      await ready(`${base}/api/natcon.php?action=public_events`, server);
      const catalogueResponse = await fetch(`${base}/api/natcon.php?action=public_events`);
      const catalogue = await catalogueResponse.json();
      assert.equal(catalogueResponse.status, 200);
      assert.equal(catalogue.ok, true);
      assert(catalogue.data.some(event => event.event_id === eventId));

      const eventResponse = await fetch(`${base}/api/natcon.php?action=event&event_id=${eventId}`);
      const selected = await eventResponse.json();
      assert.equal(selected.data.event_id, Number(eventId));
      assert.equal(selected.data.ticket_types[0].ticket_type, 'HTTP Admission');

      const loginResponse=await fetch(`${base}/api/natcon.php?action=login`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({email:'admin@example.test',password:'e2e-test-password'})});
      const login=await loginResponse.json(),cookie=loginResponse.headers.get('set-cookie')?.split(';')[0];
      assert.equal(loginResponse.status,200);assert(login.data.csrf);assert(cookie);
      const couponsResponse=await fetch(`${base}/api/natcon.php?action=coupons`,{headers:{Cookie:cookie}});assert.equal(couponsResponse.status,200);assert.deepEqual((await couponsResponse.json()).data,[]);
      const saveCouponResponse=await fetch(`${base}/api/natcon.php?action=save_coupon`,{method:'POST',headers:{'content-type':'application/json',Cookie:cookie,'X-CSRF-Token':login.data.csrf},body:JSON.stringify({event_id:eventId,coupon_code:'HTTP10',title:'HTTP Coupon',subtitle:'Test offer',description:'Temporary E2E offer',discount_type:'percent',coupon_val:'10',min_amt:'1000',expire_date:'2026-12-31',usage_limit:'2',status:'1'})});
      const savedCoupon=await saveCouponResponse.json();assert.equal(saveCouponResponse.status,200,JSON.stringify(savedCoupon));assert.equal(savedCoupon.data.saved,true);
      const couponsAfterSave=await fetch(`${base}/api/natcon.php?action=coupons`,{headers:{Cookie:cookie}});assert.equal((await couponsAfterSave.json()).data[0].coupon_code,'HTTP10');
      const contentResponse=await fetch(`${base}/api/natcon.php?action=save_event_content`,{method:'POST',headers:{'content-type':'application/json',Cookie:cookie,'X-CSRF-Token':login.data.csrf},body:JSON.stringify({kind:'artist',event_id:eventId,artist_name:'HTTP Speaker',artist_role:'Guest',img:'0',status:'1'})});assert.equal(contentResponse.status,200,JSON.stringify(await contentResponse.clone().json()));
      const contentList=await fetch(`${base}/api/natcon.php?action=event_content&kind=artist`,{headers:{Cookie:cookie}});assert.equal((await contentList.json()).data[0].title,'HTTP Speaker');
      const imageResponse=await fetch(`${base}/api/natcon.php?action=save_event_content`,{method:'POST',headers:{'content-type':'application/json',Cookie:cookie,'X-CSRF-Token':login.data.csrf},body:JSON.stringify({kind:'gallery',event_id:eventId,title:'HTTP gallery',img:'iVBORw0KGgo=',status:'1'})});assert.equal(imageResponse.status,200,JSON.stringify(await imageResponse.clone().json()));const detailResponse=await fetch(`${base}/api/mobile.php?client=user_api&endpoint=u_event_data.php`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({event_id:eventId})});const detailText=await detailResponse.text();assert.equal(detailResponse.status,200,detailText);const mediaEvent=JSON.parse(detailText),mediaUrl=mediaEvent.EventData.event_gallery[0],assetId=mediaUrl.match(/asset_id=(\d+)/)?.[1];assert(assetId);const servedMedia=await fetch(`${base}/api/mobile-media.php?asset_id=${assetId}`);assert.equal(servedMedia.status,200);assert.equal(servedMedia.headers.get('content-type'),'image/png');
      const forbiddenContent=await fetch(`${base}/api/natcon.php?action=save_event_content`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({kind:'facility',event_id:eventId,title:'Unauthorized'})});assert.equal(forbiddenContent.status,401);
      const attendeeResponse=await fetch(`${base}/api/mobile.php?client=user_api&endpoint=u_reg_user.php`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({name:'HTTP Attendee',email:'photo@example.test',ccode:'+234',mobile:'08000008888',password:'photo-test-password'})});const attendee=await attendeeResponse.json();assert.equal(attendeeResponse.status,200,JSON.stringify(attendee));const accessToken=attendee.AccessToken,uid=attendee.UserLogin.id;
      const photoResponse=await fetch(`${base}/api/mobile.php?client=user_api&endpoint=pro_image.php`,{method:'POST',headers:{'content-type':'application/json',Authorization:`Bearer ${accessToken}`},body:JSON.stringify({uid,img:'iVBORw0KGgo='})});const photo=await photoResponse.json();assert.equal(photoResponse.status,200,JSON.stringify(photo));assert.match(photo.UserLogin.pro_pic,/account_asset_id=/);const photoAssetId=photo.UserLogin.pro_pic.match(/account_asset_id=(\d+)/)[1];const photoMedia=await fetch(`${base}/api/mobile-media.php?account_asset_id=${photoAssetId}`);assert.equal(photoMedia.status,200);assert.equal(photoMedia.headers.get('content-type'),'image/png');

      const checkoutResponse = await fetch(`${base}/api/natcon.php?action=register`, {
        method: 'POST', headers: {'content-type':'application/json'},
        body: JSON.stringify({event_id:eventId,ticket_type_id:selected.data.ticket_types[0].typeid,consent:true,payer_name:'E2E Test',payer_email:'e2e@example.test',payer_phone:'08000000001',delegates:[{name:'E2E Delegate',email:'delegate@example.test',course:'Studies',institution:'Test Institution',level:'Graduate',whatsapp:'08000000002',calling_line:'',state_origin:'Osun',times_attended:0}]})
      });
      const checkout = await checkoutResponse.json();
      assert.equal(checkoutResponse.status, 200, JSON.stringify(checkout));
      assert.equal(checkout.data.amount_kobo, 321050);
      assert.equal(checkout.data.event_id, Number(eventId));
      assert.equal(String(checkout.data.ticket_type_id), selected.data.ticket_types[0].typeid);

      const receiptPdf=Buffer.from('%PDF-1.4\n1 0 obj <<>> endobj\ntrailer <<>>\n%%EOF\n').toString('base64');
      const transferRegistration={event_id:eventId,ticket_type_id:selected.data.ticket_types[0].typeid,consent:true,payer_name:'Transfer Test',payer_email:'transfer@example.test',payer_phone:'08000000003',payment_method:'transfer_new',delegates:[{name:'Transfer Delegate',email:'transfer-delegate@example.test',course:'Studies',institution:'Test Institution',level:'Graduate',whatsapp:'08000000004',calling_line:'',state_origin:'Osun',times_attended:0}]};
      const missingReceipt=await fetch(`${base}/api/natcon.php?action=register`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify(transferRegistration)});
      assert.equal(missingReceipt.status,400,'a new bank transfer must include a receipt');
      const transferResponse=await fetch(`${base}/api/natcon.php?action=register`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({...transferRegistration,receipt_url:`data:application/pdf;base64,${receiptPdf}`})});
      const transferOrder=await transferResponse.json();assert.equal(transferResponse.status,200,JSON.stringify(transferOrder));assert.equal(transferOrder.data.status,'awaiting_review');assert.equal(transferOrder.data.receipt_url,undefined,'the public order response must not echo receipt contents');
      const wrongMime=await fetch(`${base}/api/natcon.php?action=register`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({...transferRegistration,receipt_url:`data:image/png;base64,${receiptPdf}`})});
      assert.equal(wrongMime.status,400,'receipt MIME must match its decoded file content');
      const prepaidResponse=await fetch(`${base}/api/natcon.php?action=register`,{method:'POST',headers:{'content-type':'application/json'},body:JSON.stringify({...transferRegistration,payer_email:'prepaid@example.test',payment_method:'transfer_prepaid',receipt_url:`data:application/pdf;base64,${receiptPdf}`,delegates:transferRegistration.delegates.map(delegate=>({...delegate,delegate_card_id:'TAA/NC/REFORMATION/010'}))})});
      const prepaidOrder=await prepaidResponse.json();assert.equal(prepaidResponse.status,200,JSON.stringify(prepaidOrder));assert.equal(prepaidOrder.data.status,'awaiting_review');
      const transferList=await fetch(`${base}/api/natcon.php?action=transfers`,{headers:{Cookie:cookie}});const listedTransfers=(await transferList.json()).data;
      assert(listedTransfers.some(transfer=>transfer.reference===transferOrder.data.reference&&transfer.receipt_url.startsWith('data:application/pdf;base64,')),'Finance can retrieve submitted receipt data');
      console.log('PASS public event checkout, Admin session/CSRF event content, and authenticated attendee photo HTTP flows');
    } finally { server.kill(); }
  } finally { fs.rmSync(temp, {recursive:true,force:true}); }
})().catch(error => { console.error(error); process.exitCode = 1; });
