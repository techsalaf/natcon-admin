(function () {
  'use strict';
  const C = window.NatconOperations;
  const api = new C.Api('../api/natcon.php', window.fetch.bind(window));
  const $ = (id) => document.getElementById(id);
  let user = null, activeView = 'overview', stream = null, scanTimer = null;
  let scanning = false, checking = false, selectedToken = '', approvalReference = '', cancelReference = '', payoutReviewId = '', payoutReviewStatus = '', noticeTimer;
  let delegateRequest = 0;
  const titles = { overview: 'Conference overview', delegates: 'Delegate register', events: 'Events & tickets', scanner: 'Welcome desk', transfers: 'Bank transfers', payouts: 'Payouts' };
  let catalogue = { events: [], categories: [], ticket_types: [] };
  function node(tag, text, className) {
    const element = document.createElement(tag);
    if (text !== undefined) element.textContent = text;
    if (className) element.className = className;
    return element;
  }
  function showError(id, error) { $(id).textContent = error.message || String(error); $(id).hidden = false; }
  function notify(message) {
    clearTimeout(noticeTimer); $('notice').textContent = message; $('notice').hidden = false;
    noticeTimer = setTimeout(() => { $('notice').hidden = true; }, 6500);
  }
  async function busy(button, task) {
    const before = button.disabled; button.disabled = true; button.setAttribute('aria-busy', 'true');
    try { return await task(); }
    finally { button.disabled = before; button.removeAttribute('aria-busy'); }
  }
  function signedOut() {
    stopCamera(); user = null; selectedToken = ''; api.csrf = ''; delegateRequest++;
    $('app').hidden = true; $('login-view').hidden = false; $('loading').hidden = true;
    $('approve-dialog').close(); $('payout-review-dialog').close(); $('event-dialog').close(); $('ticket-type-dialog').close(); $('password').value = ''; $('delegate-rows').replaceChildren(); $('transfer-list').replaceChildren(); $('payout-list').replaceChildren();
    $('scan-result').replaceChildren(node('h2', 'Waiting for a ticket')); $('logistics').hidden = true;
    $('email').focus();
  }
  function handleError(error) {
    if (error.status === 401) { signedOut(); showError('login-error', new Error('Your session ended. Sign in again.')); }
    else showError('page-error', error);
  }
  async function signedIn(session) {
    user = session.user; $('staff-name').textContent = user.name; $('staff-role').textContent = user.role;
    $('staff-avatar').textContent = String(user.name || 'T').substring(0, 1).toUpperCase();
    document.querySelectorAll('[data-finance]').forEach((item) => { item.hidden = !C.canFinance(user); });
    document.querySelectorAll('[data-admin]').forEach((item) => { item.hidden = user.role !== 'admin'; });
    document.querySelectorAll('[data-view="scanner"], [data-go="scanner"]').forEach((item) => { item.hidden = !C.canCheckin(user); });
    $('login-view').hidden = true; $('app').hidden = false; $('loading').hidden = true; $('password').value = '';
    await changeView('overview');
  }
  async function changeView(view) {
    if (!titles[view] || (['transfers', 'payouts'].includes(view) && !C.canFinance(user)) || (view === 'scanner' && !C.canCheckin(user)) || (view === 'events' && user?.role !== 'admin')) return;
    if (view !== 'scanner') stopCamera();
    activeView = view; $('page-error').hidden = true; $('page-title').textContent = titles[view];
    document.querySelectorAll('.view').forEach((section) => { section.hidden = section.id !== 'view-' + view; });
    document.querySelectorAll('[data-view]').forEach((button) => {
      const active = button.dataset.view === view;
      button.classList.toggle('active', active); if (active) button.setAttribute('aria-current', 'page'); else button.removeAttribute('aria-current');
    });
    try { await refresh(); } catch (error) { handleError(error); }
  }
  async function refresh() {
    if (activeView === 'overview') await loadDashboard();
    if (activeView === 'delegates') await loadDelegates();
    if (activeView === 'transfers') await loadTransfers();
    if (activeView === 'payouts') await loadPayouts();
    if (activeView === 'events') await loadCatalogue();
  }
  async function loadCatalogue() {
    catalogue = await api.request('event_catalogue');
    $('event-list').replaceChildren(); $('event-empty').hidden = catalogue.events.length > 0;
    catalogue.events.forEach((event) => {
      const card = node('article', undefined, 'transfer-card'), info = node('div'), actions = node('div', undefined, 'transfer-right');
      info.append(node('h3', event.event_title), node('p', `${event.event_start_date || 'Date not set'} · ${event.event_place_name || event.event_address || 'Venue not set'}`), node('p', `${event.event_status} · ${event.total_book_ticket || 0} paid delegates`));
      const edit = node('button', 'Edit event', 'secondary'); edit.addEventListener('click', () => openEventEditor(event)); actions.append(edit);
      if (!['cancelled','completed','archived'].includes(event.event_status)) {
        const complete = node('button', 'Mark completed', 'secondary'); complete.addEventListener('click', () => updateEventStatus(event, 'complete')); actions.append(complete);
        const cancel = node('button', 'Cancel event', 'secondary'); cancel.addEventListener('click', () => updateEventStatus(event, 'cancel')); actions.append(cancel);
      }
      card.append(info, actions); $('event-list').append(card);
    });
    $('event-category').replaceChildren(); $('ticket-event').replaceChildren();
    catalogue.categories.forEach((category) => { const option = new Option(category.title, category.id); $('event-category').add(option); });
    catalogue.events.forEach((event) => { const option = new Option(event.event_title, event.event_id); $('ticket-event').add(option); });
    $('ticket-type-rows').replaceChildren(); $('ticket-type-empty').hidden = catalogue.ticket_types.length > 0;
    catalogue.ticket_types.forEach((ticket) => {
      const row = document.createElement('tr'); row.append(detailCell(ticket.type, ticket.description), detailCell(ticket.event_title), detailCell(C.money(Math.round(Number(ticket.price) * 100))), detailCell(ticket.tlimit === '0' ? 'Unlimited' : ticket.tlimit), detailCell(ticket.status === '1' ? 'Active' : 'Inactive'));
      const actionCell = node('td'), edit = node('button', 'Edit', 'text-button'); edit.addEventListener('click', () => openTicketEditor(ticket)); actionCell.append(edit); row.append(actionCell); $('ticket-type-rows').append(row);
    });
  }
  async function updateEventStatus(event, statusAction) {
    const verb=statusAction==='cancel'?'cancel':'mark completed';
    const consequence=statusAction==='cancel'?' Paid orders stay recorded and refunds must be handled by staff.':'';
    if (!window.confirm(`${verb[0].toUpperCase()+verb.slice(1)} “${event.event_title}”?${consequence}`)) return;
    try { await api.request('event_status',{event_id:event.event_id,status_action:statusAction}); notify(statusAction==='cancel'?'Event cancelled. Paid orders are unchanged.':'Event marked completed.'); await loadCatalogue(); }
    catch (error) { if (error.status===401) handleError(error); else notify(error.message); }
  }
  function openEventEditor(event) {
    $('event-form').reset(); $('event-error').hidden = true;
    $('event-dialog-title').textContent = event ? 'Edit event' : 'Create event'; $('event-id').value = event?.event_id || '';
    $('event-title').value = event?.event_title || ''; $('event-category').value = event?.event_cat_id || catalogue.categories[0]?.id || '';
    $('event-venue').value = event?.event_place_name || event?.event_address || ''; $('event-description').value = event?.event_description || '';
    $('event-date').value = event?.event_start_date || ''; $('event-start').value = (event?.event_start_time || '09:00').slice(0,5); $('event-end').value = (event?.event_end_time || '17:00').slice(0,5);
    $('event-latitude').value = event?.event_latitude || ''; $('event-longitude').value = event?.event_longtitude || '';
    $('event-status').value = event?.event_status || 'draft'; $('event-disclaimer').value = event?.event_disclaimer || ''; $('event-tags').value = event?.event_tags || ''; $('event-videos').value = event?.event_vurls || '';
    $('event-dialog').showModal(); $('event-title').focus();
  }
  function openTicketEditor(ticket) {
    $('ticket-type-form').reset(); $('ticket-type-error').hidden = true; $('ticket-type-title').textContent = ticket ? 'Edit ticket type' : 'Add ticket type';
    $('ticket-type-id').value = ticket?.id || ''; $('ticket-event').value = ticket?.event_id || catalogue.events[0]?.event_id || '';
    $('ticket-label').value = ticket?.type || ''; $('ticket-description').value = ticket?.description || ''; $('ticket-price').value = ticket?.price || '';
    $('ticket-capacity').value = ticket?.tlimit || 0; $('ticket-status').value = ticket?.status === '0' ? 'inactive' : 'active';
    $('ticket-type-dialog').showModal(); $('ticket-label').focus();
  }
  async function loadDashboard() {
    const data = await api.request('dashboard');
    if (!user) return;
    $('metric-total').textContent = Number(data.total_delegates || 0).toLocaleString();
    $('metric-paid').textContent = Number(data.paid_delegates || 0).toLocaleString();
    $('metric-arrived').textContent = Number(data.checked_in || 0).toLocaleString();
    $('metric-revenue').textContent = C.money(data.revenue_kobo);
    $('pending-label').textContent = Number(data.pending_transfers || 0).toLocaleString() + ' payment(s) awaiting review';
    const chapters = data.chapters || []; $('chapter-count').textContent = chapters.length + ' chapters';
    $('chapters').replaceChildren();
    if (!chapters.length) $('chapters').append(node('p', 'Chapter representation will appear as delegates register.', 'empty'));
    const max = Math.max(1, ...chapters.map((c) => Number(c.total)));
    chapters.forEach((chapter) => {
      const row = node('div', undefined, 'chapter-row'), meta = node('div', undefined, 'chapter-meta');
      const name = chapter.chapter || 'Independent delegates';
      meta.append(node('strong', name), node('span', chapter.total + ' delegates'));
      const track = node('div', undefined, 'chapter-track'), progress = document.createElement('progress');
      progress.max = max; progress.value = Number(chapter.total); progress.setAttribute('aria-label', name + ': ' + chapter.total + ' delegates');
      track.append(progress); row.append(meta, track); $('chapters').append(row);
    });
  }
  function detailCell(primary, secondary) {
    const td = node('td'); td.append(node('strong', primary || '—')); if (secondary) td.append(node('small', secondary)); return td;
  }
  async function loadDelegates() {
    const request = ++delegateRequest;
    $('delegate-count').textContent = 'Loading registrations…';
    const records = await api.request('delegates', undefined, { q: $('delegate-query').value.trim(), status: $('delegate-status').value });
    if (request !== delegateRequest || !user) return;
    $('delegate-rows').replaceChildren(); $('delegate-count').textContent = records.length + ' delegate(s) shown';
    $('delegate-empty').hidden = records.length > 0;
    records.forEach((delegate) => {
      const tr = node('tr');
      tr.append(detailCell(delegate.name, delegate.email || delegate.whatsapp), detailCell(delegate.course || 'Course not supplied', [delegate.institution, delegate.level, delegate.state_origin, `${delegate.times_attended || 0} NATCONs`].filter(Boolean).join(' · ')), detailCell(delegate.reference, 'Order total ' + C.money(delegate.amount_kobo)));
      const payment = node('td'), safeStatus = ['paid', 'pending', 'cancelled'].includes(delegate.status) ? delegate.status : '';
      payment.append(node('span', (delegate.status || 'pending').replace(/_/g, ' '), 'status ' + safeStatus)); tr.append(payment);
      tr.append(detailCell(delegate.checked_in ? 'Arrived' : 'Not arrived'));
      const actions = node('td');
      if (delegate.ticket_token && delegate.status === 'paid' && C.canCheckin(user)) {
        const check = node('button', 'Check in', 'text-button');
        check.addEventListener('click', async () => { await changeView('scanner'); $('ticket-code').value = delegate.ticket_token; $('ticket-code').focus(); });
        actions.append(check);
      }
      if (C.canFinance(user) && delegate.status === 'paid') {
        const resend = node('button', 'Resend ticket', 'text-button');
        resend.addEventListener('click', () => busy(resend, async () => {
          try { await api.request('resend', { reference: delegate.reference }); notify('Ticket delivery queued for the registration email.'); }
          catch (error) { handleError(error); }
        })); actions.append(resend);
      }
      if (C.canFinance(user) && !['cancelled', 'refunded'].includes(delegate.status)) {
        const cancel = node('button', 'Cancel / refund', 'text-button danger-button');
        cancel.addEventListener('click', () => {
          cancelReference = delegate.reference; $('cancel-form').reset(); $('cancel-error').hidden = true;
          $('cancel-details').textContent = 'Order ' + delegate.reference + '. This affects every delegate on this order.';
          $('cancel-dialog').showModal();
        }); actions.append(cancel);
      }
      if (!actions.childNodes.length) actions.textContent = '—';
      tr.append(actions); $('delegate-rows').append(tr);
    });
  }
  async function loadTransfers() {
    const transfers = await api.request('transfers');
    if (!user) return;
    $('transfer-list').replaceChildren(); $('transfer-count').textContent = transfers.length + ' pending'; $('transfer-empty').hidden = transfers.length > 0;
    transfers.forEach((transfer) => {
      const card = node('article', undefined, 'transfer-card'), info = node('div'), right = node('div', undefined, 'transfer-right');
      info.append(node('h3', transfer.payer_name || transfer.name || transfer.sender_name || 'Registration payment'));
      info.append(node('p', 'Registration: ' + transfer.reference));
      info.append(node('p', 'Sender: ' + (transfer.sender_name || 'Not supplied')));
      info.append(node('p', 'Bank reference: ' + (transfer.bank_reference || 'Not supplied')));
      info.append(node('p', 'Payment date reported: ' + (transfer.paid_on || 'Not supplied')));
      const amount = transfer.amount_kobo ?? transfer.total_kobo;
      right.append(node('p', C.money(amount), 'amount'));
      const review = node('button', 'Review & approve', 'primary');
      review.addEventListener('click', () => {
        approvalReference = transfer.reference; $('approve-details').textContent = transfer.reference + ' · ' + C.money(amount) + ' · ' + (transfer.sender_name || transfer.payer_name || '');
        $('approve-form').reset(); $('approve-error').hidden = true; $('approve-dialog').showModal(); $('reconciliation-note').focus();
      }); right.append(review); card.append(info, right); $('transfer-list').append(card);
    });
  }
  async function loadPayouts() {
    const data = await api.request('payouts');
    if (!user) return;
    const balance = data.balance || {};
    $('payout-revenue').textContent = C.money(balance.revenue_kobo);
    $('payout-reserved').textContent = C.money(balance.reserved_kobo);
    $('payout-available').textContent = C.money(balance.available_kobo);
    const rows = data.items || [];
    $('payout-list').replaceChildren(); $('payout-count').textContent = rows.length + ' request(s)'; $('payout-empty').hidden = rows.length > 0;
    rows.forEach((payout) => {
      const card = node('article', undefined, 'transfer-card'), info = node('div'), right = node('div', undefined, 'transfer-right');
      info.append(node('h3', payout.requester || 'Admin request'));
      info.append(node('p', 'Requested ' + C.dateTime(payout.r_date)));
      info.append(node('p', payout.r_type + ' · ' + (payout.bank_name || '')));
      info.append(node('p', (payout.acc_name || '') + ' · ' + (payout.acc_number || '')));
      if (payout.note) info.append(node('p', 'Request note: ' + payout.note));
      const status = node('span', payout.status, 'status ' + (payout.status === 'rejected' ? 'cancelled' : payout.status === 'paid' ? 'paid' : 'pending'));
      info.append(status); right.append(node('p', C.money(payout.amount_kobo), 'amount'));
      if (user.role === 'finance' && payout.status === 'pending') {
        const approve = node('button', 'Approve', 'primary'); approve.addEventListener('click', () => openPayoutReview(payout, 'approved')); right.append(approve);
        const reject = node('button', 'Reject', 'secondary'); reject.addEventListener('click', () => openPayoutReview(payout, 'rejected')); right.append(reject);
      }
      if (user.role === 'finance' && payout.status === 'approved') {
        const paid = node('button', 'Record transfer paid', 'primary'); paid.addEventListener('click', () => openPayoutReview(payout, 'paid')); right.append(paid);
      }
      card.append(info, right); $('payout-list').append(card);
    });
  }
  function openPayoutReview(payout, status) {
    payoutReviewId = payout.payout_id; payoutReviewStatus = status;
    $('payout-review-title').textContent = status === 'paid' ? 'Record manual transfer' : status[0].toUpperCase() + status.slice(1) + ' payout';
    $('payout-review-details').textContent = payout.requester + ' · ' + C.money(payout.amount_kobo) + ' · ' + payout.bank_name + ' · ' + payout.acc_number;
    $('payout-review-note').value = ''; $('payout-review-note').minLength = status === 'paid' ? 8 : 4;
    $('payout-review-note').placeholder = status === 'paid' ? 'Bank transfer reference (at least 8 characters) and note' : 'Reason for the decision';
    $('payout-review-error').hidden = true; $('payout-review-dialog').showModal(); $('payout-review-note').focus();
  }
  function stopCamera() {
    scanning = false; clearTimeout(scanTimer);
    if (stream) stream.getTracks().forEach((track) => track.stop());
    stream = null; $('camera').srcObject = null; $('camera').hidden = true;
    $('camera-placeholder').hidden = false; $('start-camera').hidden = false; $('stop-camera').hidden = true;
  }
  async function startCamera() {
    if (!window.isSecureContext || !navigator.mediaDevices?.getUserMedia) {
      $('camera-message').textContent = 'Camera access is unavailable here. Use HTTPS, or enter the ticket code below.'; return;
    }
    if (!('BarcodeDetector' in window)) {
      $('camera-message').textContent = 'This browser does not support built-in QR scanning. Use a supported Android Chromium browser, a USB QR scanner, or type the ticket code below.'; return;
    }
    try {
      const supported = await window.BarcodeDetector.getSupportedFormats();
      if (!supported.includes('qr_code')) throw new Error('QR code scanning is unavailable. Enter the ticket code below.');
      const detector = new window.BarcodeDetector({ formats: ['qr_code'] });
      stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: 'environment' } }, audio: false });
      // Do not keep the camera alive if sign-out/navigation occurred during permission approval.
      if (!user || activeView !== 'scanner') { stopCamera(); return; }
      $('camera').srcObject = stream; $('camera').hidden = false; $('camera-placeholder').hidden = true;
      $('start-camera').hidden = true; $('stop-camera').hidden = false; await $('camera').play(); scanning = true;
      $('camera-message').textContent = 'Point the camera at one QR code. Scanning stops after a ticket is read.';
      const detect = async () => {
        if (!scanning) return;
        try {
          const codes = await detector.detect($('camera'));
          if (codes.length && scanning) { const raw = codes[0].rawValue; stopCamera(); $('ticket-code').value = raw; await checkIn(raw); return; }
        } catch (_) { /* A frame may not be ready yet; manual entry remains available. */ }
        if (scanning) scanTimer = setTimeout(detect, 250);
      };
      await detect();
    } catch (error) {
      stopCamera(); $('camera-message').textContent = error.name === 'NotAllowedError' ? 'Camera permission was not granted. Allow it in browser settings or enter the ticket code below.' : 'Camera could not start. Enter the ticket code below.';
    }
  }
  function renderResult(kind, title, message, delegate, checkedAt) {
    const result = $('scan-result'); result.className = 'panel result-card ' + kind; result.replaceChildren();
    result.append(node('span', kind === 'accepted' ? '✓' : kind === 'duplicate' ? '!' : '×', 'result-symbol'), node('p', 'TICKET VERIFICATION', 'eyebrow'), node('h2', title), node('p', message));
    if (delegate) {
      const details = node('dl', undefined, 'result-details');
      [['Delegate', delegate.name], ['Chapter', delegate.chapter || 'Independent'], ['Reference', delegate.reference], ['Recorded', checkedAt ? C.dateTime(checkedAt) : null]].forEach(([label, value]) => {
        if (value) { const row = node('div'); row.append(node('dt', label), node('dd', value)); details.append(row); }
      }); result.append(details);
    }
  }
  async function checkIn(raw) {
    if (checking) return;
    selectedToken = ''; $('logistics').hidden = true; $('page-error').hidden = true;
    let token;
    try { token = C.ticketToken(raw); } catch (error) { renderResult('rejected', 'Check the ticket code', error.message); return; }
    checking = true;
    const submit = $('checkin-form').querySelector('button'); submit.disabled = true;
    try {
      const mode = $('checkin-mode').value;
      const data = await api.request('checkin', { token, mode });
      if (!user) return;
      if (!['accepted', 'already_checked_in'].includes(data.result)) throw new Error('The server did not confirm admission. Ask the technical team to check this ticket.');
      selectedToken = token; $('logistics').hidden = false;
      const duplicate = data.result === 'already_checked_in';
      renderResult(duplicate ? 'duplicate' : 'accepted', duplicate ? 'Already checked in' : 'Welcome to NATCON!', duplicate ? 'This attendance entry already exists. Check the recorded time below.' : (mode === 'reentry' ? 'Re-entry recorded.' : mode === 'daily' ? 'Today’s attendance recorded.' : 'Ticket valid. First arrival recorded.'), data.delegate, data.checked_at);
    } catch (error) {
      if (error.status === 401) { handleError(error); return; }
      const message = error.message;
      const title = /cancel/i.test(message) ? 'Ticket cancelled' : /unpaid|not paid|payment|pending/i.test(message) ? 'Payment not confirmed' : 'Admission not confirmed';
      renderResult('rejected', title, message);
    } finally { checking = false; submit.disabled = false; }
  }
  $('login-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('login-error').hidden = true;
    busy(event.submitter || $('login-form').querySelector('button'), async () => {
      try { const session = await api.request('login', { email: $('email').value.trim(), password: $('password').value }); await signedIn(session); }
      catch (error) { showError('login-error', error); }
    });
  });
  async function logout(button) {
    await busy(button, async () => {
      try { await api.request('logout', {}); signedOut(); }
      catch (error) { handleError(error); }
    });
  }
  $('logout').addEventListener('click', (event) => logout(event.currentTarget));
  const mobileLogout = node('button', 'Sign out', 'secondary mobile-signout'); mobileLogout.hidden = true;
  mobileLogout.addEventListener('click', () => logout(mobileLogout)); document.querySelector('.topbar-meta').append(mobileLogout);
  // CSS controls this mobile-only affordance; hidden is removed to keep it reachable.
  mobileLogout.hidden = false;
  document.querySelectorAll('[data-view]').forEach((button) => button.addEventListener('click', () => changeView(button.dataset.view)));
  document.querySelectorAll('[data-go]').forEach((button) => button.addEventListener('click', () => changeView(button.dataset.go)));
  $('refresh').addEventListener('click', (event) => busy(event.currentTarget, async () => { $('page-error').hidden = true; try { await refresh(); } catch (error) { handleError(error); } }));
  $('search-form').addEventListener('submit', async (event) => { event.preventDefault(); try { await loadDelegates(); } catch (error) { handleError(error); } });
  $('delegate-status').addEventListener('change', async () => { try { await loadDelegates(); } catch (error) { handleError(error); } });
  $('start-camera').addEventListener('click', (event) => busy(event.currentTarget, startCamera));
  $('stop-camera').addEventListener('click', stopCamera);
  $('checkin-form').addEventListener('submit', (event) => { event.preventDefault(); stopCamera(); checkIn($('ticket-code').value); });
  $('entitlement-form').addEventListener('submit', (event) => {
    event.preventDefault(); if (!selectedToken) return;
    busy(event.submitter || $('entitlement-form').querySelector('button'), async () => {
      try {
        const data = await api.request('entitlement', { token: selectedToken, kind: $('entitlement-kind').value, slot: $('entitlement-slot').value.trim() });
        notify(data.result === 'already_claimed' ? 'This allocation was already recorded. Do not issue it again.' : 'Allocation recorded.');
      } catch (error) { handleError(error); }
    });
  });
  $('cancel-approval').addEventListener('click', () => $('approve-dialog').close());
  $('approve-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('approve-error').hidden = true;
    if (!$('credit-confirmed').checked) return;
    busy(event.submitter || $('approve-form').querySelector('button[type="submit"]'), async () => {
      try {
        const note = C.approvalNote($('reconciliation-note').value);
        const verified_amount_kobo = C.nairaToKobo($('verified-amount').value);
        await api.request('approve_transfer', { reference: approvalReference, note, verified_amount_kobo });
        $('approve-dialog').close(); notify('Payment approved. Tickets have been issued.'); await loadTransfers();
      } catch (error) { if (error.status === 401) handleError(error); else showError('approve-error', error); }
    });
  });
  $('close-cancel').addEventListener('click', () => $('cancel-dialog').close());
  $('cancel-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('cancel-error').hidden = true;
    if (!$('cancel-confirmed').checked) return;
    busy(event.submitter || $('cancel-form').querySelector('button[type="submit"]'), async () => {
      try {
        const reason = C.approvalNote($('cancel-reason').value);
        await api.request('cancel', { reference: cancelReference, status: $('cancel-status').value, reason });
        $('cancel-dialog').close(); notify('Order status updated. Tickets for this order are no longer valid.'); await loadDelegates();
      } catch (error) { if (error.status === 401) handleError(error); else showError('cancel-error', error); }
    });
  });
  $('payout-request-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('payout-request-error').hidden = true;
    busy(event.submitter || $('payout-request-form').querySelector('button[type="submit"]'), async () => {
      try {
        const amount = $('payout-amount').value.trim(); C.nairaToKobo(amount);
        await api.request('request_payout', { amount, r_type: 'BANK Transfer', bank_name: $('payout-bank').value.trim(), acc_name: $('payout-account-name').value.trim(), acc_number: $('payout-account-number').value.trim() });
        $('payout-request-form').reset(); notify('Payout request sent to Finance for review.'); await loadPayouts();
      } catch (error) { if (error.status === 401) handleError(error); else showError('payout-request-error', error); }
    });
  });
  $('close-payout-review').addEventListener('click', () => $('payout-review-dialog').close());
  $('payout-review-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('payout-review-error').hidden = true;
    busy(event.submitter || $('payout-review-form').querySelector('button[type="submit"]'), async () => {
      try {
        const note = $('payout-review-note').value.trim();
        if (note.length < (payoutReviewStatus === 'paid' ? 8 : 4)) throw new Error(payoutReviewStatus === 'paid' ? 'Include the bank transfer reference.' : 'Enter a review note.');
        await api.request('review_payout', { payout_id: payoutReviewId, status: payoutReviewStatus, note });
        $('payout-review-dialog').close(); notify('Payout request updated.'); await loadPayouts();
      } catch (error) { if (error.status === 401) handleError(error); else showError('payout-review-error', error); }
    });
  });
  $('new-event').addEventListener('click', () => openEventEditor(null));
  $('close-event').addEventListener('click', () => $('event-dialog').close());
  $('event-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('event-error').hidden = true;
    busy(event.submitter || $('event-form').querySelector('button[type="submit"]'), async () => {
      try {
        await api.request('save_event', { event_id: $('event-id').value || null, title: $('event-title').value.trim(), cat_id: $('event-category').value, pname: $('event-venue').value.trim(), address: $('event-venue').value.trim(), cdesc: $('event-description').value, sdate: $('event-date').value, stime: $('event-start').value, etime: $('event-end').value, latitude: $('event-latitude').value, longtitude: $('event-longitude').value, status: $('event-status').value, disclaimer: $('event-disclaimer').value, tags: $('event-tags').value, vurls: $('event-videos').value });
        $('event-dialog').close(); notify('Event saved to the shared NATCON catalogue.'); await loadCatalogue();
      } catch (error) { if (error.status === 401) handleError(error); else showError('event-error', error); }
    });
  });
  $('new-ticket-type').addEventListener('click', () => {
    if (!catalogue.events.length) { notify('Create an event before adding ticket types.'); return; }
    openTicketEditor(null);
  });
  $('close-ticket-type').addEventListener('click', () => $('ticket-type-dialog').close());
  $('ticket-type-form').addEventListener('submit', (event) => {
    event.preventDefault(); $('ticket-type-error').hidden = true;
    busy(event.submitter || $('ticket-type-form').querySelector('button[type="submit"]'), async () => {
      try {
        C.nairaToKobo($('ticket-price').value);
        await api.request('save_ticket_type', { ticket_type_id: $('ticket-type-id').value || null, event_id: $('ticket-event').value, label: $('ticket-label').value.trim(), description: $('ticket-description').value, price: $('ticket-price').value.trim(), capacity: $('ticket-capacity').value, status: $('ticket-status').value });
        $('ticket-type-dialog').close(); notify('Ticket type saved to the shared NATCON catalogue.'); await loadCatalogue();
      } catch (error) { if (error.status === 401) handleError(error); else showError('ticket-type-error', error); }
    });
  });
  $('export').addEventListener('click', (event) => busy(event.currentTarget, async () => {
    try {
      const response = await fetch('../api/natcon.php?action=export', { credentials: 'same-origin', cache: 'no-store' });
      if (!response.ok) { const error = new Error('Could not export the register. Check your session and try again.'); error.status = response.status; throw error; }
      if (!response.headers.get('Content-Type')?.includes('text/csv')) throw new Error('The server did not return a CSV register.');
      const url = URL.createObjectURL(await response.blob()), link = document.createElement('a');
      link.href = url; link.download = 'natcon-2026-delegates.csv'; document.body.append(link); link.click(); link.remove(); setTimeout(() => URL.revokeObjectURL(url), 1000);
    } catch (error) { handleError(error); }
  }));
  document.addEventListener('visibilitychange', () => { if (document.hidden) stopCamera(); });
  window.addEventListener('pagehide', stopCamera);
  api.request('session').then(signedIn).catch((error) => {
    signedOut(); if (error.status !== 401) showError('login-error', error);
  });
})();
