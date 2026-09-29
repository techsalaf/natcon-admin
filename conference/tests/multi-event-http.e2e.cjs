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
const fixture = `require ${phpQuote(bootstrap)}; $db=new PDO(${phpQuote(dsn)}); Natcon\\migrate($db); $category=(string)$db->query("SELECT id FROM natcon_categories WHERE status='active' ORDER BY id LIMIT 1")->fetchColumn(); $event=Natcon\\saveOrganizerEvent($db,['title'=>'HTTP Shared Event','pname'=>'Abuja Venue','cdesc'=>'HTTP flow','sdate'=>'2026-11-02','stime'=>'09:00','etime'=>'17:00','cat_id'=>$category,'status'=>'published']); Natcon\\saveOrganizerTicketType($db,['event_id'=>$event['event_id'],'etype'=>'HTTP Admission','price'=>'3210.50','tlimit'=>'5','status'=>'1']); echo $event['event_id'];`;

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

      const checkoutResponse = await fetch(`${base}/api/natcon.php?action=register`, {
        method: 'POST', headers: {'content-type':'application/json'},
        body: JSON.stringify({event_id:eventId,ticket_type_id:selected.data.ticket_types[0].typeid,consent:true,payer_name:'E2E Test',payer_email:'e2e@example.test',payer_phone:'08000000001',delegates:[{name:'E2E Delegate',email:'delegate@example.test',course:'Studies',institution:'Test Institution',level:'Graduate',whatsapp:'08000000002',calling_line:'',state_origin:'Osun',times_attended:0}]})
      });
      const checkout = await checkoutResponse.json();
      assert.equal(checkoutResponse.status, 200, JSON.stringify(checkout));
      assert.equal(checkout.data.amount_kobo, 321050);
      assert.equal(checkout.data.event_id, Number(eventId));
      assert.equal(String(checkout.data.ticket_type_id), selected.data.ticket_types[0].typeid);
      console.log('PASS public event catalogue → selected event/ticket API → server-priced registration HTTP flow');
    } finally { server.kill(); }
  } finally { fs.rmSync(temp, {recursive:true,force:true}); }
})().catch(error => { console.error(error); process.exitCode = 1; });
