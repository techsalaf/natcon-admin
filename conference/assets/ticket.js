'use strict';
(async () => {
  const {api,escape} = window.NatconUI;
  const status = document.getElementById('ticket-status');
  const token = decodeURIComponent(location.hash.slice(1)) || new URLSearchParams(location.search).get('token');
  if (!token) { status.textContent = 'This ticket link is incomplete. Use “Find my registration” to recover your secure link.'; return; }
  history.replaceState(null,'',`${location.pathname}#${encodeURIComponent(token)}`);
  try {
    const result = await api('ticket',{token},'GET');
    const delegate = result.delegate || result;
    const event = result.event || {};
    const qr = `../api/natcon.php?action=qr&token=${encodeURIComponent(token)}`;
    document.getElementById('ticket').innerHTML = `<div class="ticket-header"><p class="eyebrow">TAA · REFORMATION 2026</p><h1>Knowledge<br>with Purpose.</h1><p>7th Annual National Conference</p></div><div class="ticket-body"><span class="status-pill">CONFIRMED DELEGATE</span><div class="ticket-identity"><div><p class="order-label">DELEGATE NAME</p><h2 class="ticket-name">${escape(delegate.name)}</h2><p>${escape(delegate.chapter || '')}</p><p class="muted">${escape(result.reference || result.order?.reference || delegate.reference || '')}</p></div><img class="ticket-qr" src="${qr}" alt="Your personal admission QR code" width="190" height="190"></div><div class="ticket-detail"><strong>October 1–4, 2026</strong><p>${escape(event.venue || 'Shaykh Idrees Fazazi Mogaji Central Mosque, Iwo, Osun State')}</p><p>Present this QR code to a registrar. This ticket is for the named delegate. Keep your code private.</p></div></div>`;
    document.getElementById('ticket').hidden = false; document.getElementById('ticket-tools').hidden = false; status.hidden = true;
    document.querySelector('.ticket-qr').onerror = () => { status.hidden = false; status.textContent = 'Your ticket is confirmed, but the QR image could not load. Refresh before printing, or contact the registration team with your reference.'; document.getElementById('print-ticket').disabled = true; };
    document.getElementById('print-ticket').onclick = () => window.print();
    document.getElementById('save-qr').onclick = async () => { try { const response = await fetch(qr,{cache:'no-store'}); if (!response.ok || !response.headers.get('content-type')?.startsWith('image/')) throw new Error('QR image is unavailable.'); const url = URL.createObjectURL(await response.blob()); const link = document.createElement('a'); link.href=url; link.download='NATCON-2026-ticket-QR.png'; link.click(); setTimeout(() => URL.revokeObjectURL(url),1000); } catch (error) { status.hidden=false; status.textContent=error.message; } };
  } catch (error) { status.className='notice error'; status.textContent=error.message; }
})();
