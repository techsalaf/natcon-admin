'use strict';
(() => {
  const apiBase = '../api/natcon.php';
  const $ = id => document.getElementById(id);
  const money = value => new Intl.NumberFormat('en-NG', {style:'currency',currency:'NGN',maximumFractionDigits:0}).format(value / 100);
  let event = {price_kobo:800000,payment_enabled:false};
  let selectedTicketTypeId = '';
  let order = null;
  let delegateNumber = 0;
  let currentStep = 1;

  const escape = value => String(value ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    const delegateIdPattern = /^TAA\/NC\/REFORMATION\/\d{3}$/;
    const validDelegateId = value => delegateIdPattern.test(String(value ?? '').trim().toUpperCase());
  
  async function api(action, data, method = 'POST') {
    const query = new URLSearchParams({action,...(method === 'GET' ? data : {})});
    const response = await fetch(`${apiBase}?${query}`, {method,credentials:'same-origin',cache:'no-store',headers:method === 'POST' ? {'Content-Type':'application/json'} : {},...(method === 'POST' ? {body:JSON.stringify(data)} : {})});
    let result;
    try { result = await response.json(); } catch (_) { throw new Error('The registration service is unavailable. Please try again or contact the team.'); }
    if (!response.ok || !result.ok) throw new Error(typeof result.error === 'string' ? result.error : result.error?.message || 'This request could not be completed. Please try again.');
    return result.data;
  }
  
  function notice(id, message, error = false) { const node = $(id); node.textContent = message; node.className = `notice${error ? ' error' : ''}`; node.hidden = false; }
  async function submitting(form, callback) { const button = form.querySelector('[type="submit"]'); button.disabled = true; try { await callback(); } finally { button.disabled = false; } }
  function updateTotal() { if ($('total')) $('total').textContent = money(event.price_kobo * $('delegates').children.length); }

    function selectedPaymentMethod() {
        return document.querySelector('input[name="payment_method"]:checked')?.value || 'paystack';
    }

  function updateSteps() {
    document.querySelectorAll('.form-step').forEach(s => s.classList.remove('active'));
    $(`step-${currentStep}`).classList.add('active');
        const progress = $('registration-progress');
        const progressValue = Math.round(currentStep / 3 * 100);
        progress?.setAttribute('aria-valuenow', String(progressValue));
        progress?.style.setProperty('--progress', `${progressValue}%`);
        document.querySelectorAll('.progress-bar .step-indicator').forEach((s, idx) => {
        if(idx + 1 < currentStep) { s.classList.add('completed'); s.classList.remove('active'); }
        else if(idx + 1 === currentStep) { s.classList.add('active'); s.classList.remove('completed'); }
        else { s.classList.remove('active', 'completed'); }
            if(idx + 1 === currentStep) s.setAttribute('aria-current', 'step');
            else s.removeAttribute('aria-current');
    });
    $('step-prev').style.display = currentStep > 1 ? 'block' : 'none';
    $('step-next').style.display = currentStep < 3 ? 'block' : 'none';
    $('step-submit').style.display = currentStep === 3 ? 'block' : 'none';
  }

  function validateStep(step) {
    if(step === 1) {
        const pName = $('payer-name').value.trim();
        const pEmail = $('payer-email').value.trim();
        const pPhone = $('payer-phone').value.trim();
        if(!pName || !pEmail || !pPhone) return "Please complete all billing details.";
        if(!$('payer-email').checkValidity()) return "Please provide a valid email address.";
        if(!$('privacy-consent').checked) return "Please review and accept the privacy notice to continue.";
    }
    if(step === 2) {
        if($('delegates').children.length === 0) return "Please add at least one delegate.";
        const invalid = [...$('delegates').querySelectorAll('[required]')].find(f => !f.value.trim());
        if(invalid) return "Please complete all required delegate details.";
        
        if(document.querySelector('input[name="have_paid"]:checked')?.value === 'yes') {
            const badId = [...$('delegates').querySelectorAll('[data-field="delegate_card_id"]')].find(field => !validDelegateId(field.value));
            if(badId) {
                updateDelegateIdFeedback(badId);
                badId.focus();
                return "Enter each Delegate ID in the format TAA/NC/REFORMATION/001.";
            }
        }
    }
    return null;
  }

    function updateDelegateIdFeedback(input) {
        const value = input.value.trim().toUpperCase();
        const feedback = $(`${input.id}-feedback`);
        input.value = value;
        const matchesFormat = validDelegateId(value);
        input.setAttribute('aria-invalid', value && !matchesFormat ? 'true' : 'false');
        input.setCustomValidity(value && !matchesFormat ? 'Use the format TAA/NC/REFORMATION/001.' : '');
        feedback.textContent = !value
            ? 'Format: TAA/NC/REFORMATION/001'
            : matchesFormat
                ? 'Format matches. TAA staff will confirm the ID and payment receipt.'
                : 'This does not match the required format: TAA/NC/REFORMATION/001.';
        feedback.classList.toggle('is-valid', Boolean(value && matchesFormat));
        feedback.classList.toggle('is-invalid', Boolean(value && !matchesFormat));
    }

  function togglePaymentLogic() {
      const hasPaid = document.querySelector('input[name="have_paid"]:checked')?.value === 'yes';
      const paymentMethods = [...document.querySelectorAll('input[name="payment_method"]')];
    const bankTransfer = document.querySelector('[data-bank-transfer]');
    const wasPrepaid = selectedPaymentMethod() === 'transfer_prepaid';
      const receiptWrapper = $('receipt-wrapper');
      
      [...$('delegates').querySelectorAll('.delegate-card-wrapper')].forEach(w => w.style.display = hasPaid ? 'block' : 'none');
      [...$('delegates').querySelectorAll('[data-field="delegate_card_id"]')].forEach(i => i.required = hasPaid);
      
      if(hasPaid) {
          bankTransfer.value = 'transfer_prepaid';
          paymentMethods.forEach(input => { input.checked = input === bankTransfer; input.disabled = true; });
          receiptWrapper.style.display = 'block';
          $('receipt-file').required = true;
          $('payment-instructions').textContent = "Bank transfer is selected because you said you have paid. Enter each delegate's ID and attach the transfer receipt. TAA staff will verify both before tickets are issued.";
      } else {
                    bankTransfer.value = 'transfer_new';
                    paymentMethods.forEach(input => { input.disabled = false; });
                    if(wasPrepaid) paymentMethods.forEach(input => { input.checked = input.value === 'paystack'; });
          receiptWrapper.style.display = 'none';
          $('receipt-file').required = false;
                    updatePaymentInstructions();
      }
  }

    function setupRevealAnimations() {
        const elements = [...(document.querySelectorAll?.('[data-aos]') || [])];
        if(!elements.length) return;
        if(!('IntersectionObserver' in window)) {
            elements.forEach(element => element.classList.add('is-visible'));
            return;
        }
        const observer = new IntersectionObserver(entries => entries.forEach(entry => {
            if(entry.isIntersecting) {
                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            }
        }), {threshold: 0.12, rootMargin: '0px 0px -36px 0px'});
        elements.forEach(element => observer.observe(element));
    }

    function updatePaymentInstructions() {
        const method = selectedPaymentMethod();
        const needsReceipt = method === 'transfer_new';
        $('receipt-wrapper').style.display = needsReceipt ? 'block' : 'none';
        $('receipt-file').required = needsReceipt;
        if(method === 'transfer_new') $('payment-instructions').textContent = 'Complete the bank transfer, then attach an image or PDF receipt. TAA staff will verify the payment before issuing tickets.';
        else if(method === 'paystack') $('payment-instructions').textContent = 'After registration, you will continue to the secure Paystack checkout.';
        else if(method === 'cash') $('payment-instructions').textContent = 'Your registration stays pending until cash payment is collected at the venue.';
    }

  async function convertFileToBase64(file) {
      return new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.readAsDataURL(file);
          reader.onload = () => resolve(reader.result);
          reader.onerror = error => reject(error);
      });
  }

  function addDelegate() {
    if ($('delegates').children.length >= 50) return;
    const id = ++delegateNumber;
    const fieldset = document.createElement('fieldset');
    fieldset.className = 'delegate-block';
    
    // Smooth transition in
    fieldset.style.opacity = '0';
    fieldset.style.transform = 'translateY(10px)';
    
    fieldset.innerHTML = `<h4>Delegate ${id} ${id > 1 ? '<button type="button" class="remove-delegate">Remove</button>' : '<button type="button" class="copy-contact">Copy payer details</button>'}</h4>
<div class="field"><label for="d${id}-name">Full name</label><input id="d${id}-name" data-field="name" required maxlength="120" placeholder="Name as it should appear on the ticket"></div>
<div class="field-row"><div class="field"><label for="d${id}-email">Email address</label><input id="d${id}-email" data-field="email" type="email" required placeholder="you@example.com"></div>
<div class="field"><label for="d${id}-whatsapp">WhatsApp number</label><input id="d${id}-whatsapp" data-field="whatsapp" type="tel" required placeholder="+234..."></div></div>
<div class="field-row"><div class="field"><label for="d${id}-state-origin">State of origin</label><input id="d${id}-state-origin" data-field="state_origin" required placeholder="e.g. Osun"></div>
<div class="field"><label for="d${id}-course">Course / field of study</label><input id="d${id}-course" data-field="course" required placeholder="Course"></div></div>
<div class="field-row"><div class="field"><label for="d${id}-institution">Institution</label><input id="d${id}-institution" data-field="institution" required placeholder="Institution"></div>
<div class="field"><label for="d${id}-level">Current level</label><select id="d${id}-level" data-field="level" required><option value="">Choose your level</option><option>Secondary school</option><option>Undergraduate</option><option>Graduate</option><option>NYSC</option><option>Postgraduate</option><option>Other</option></select></div></div>
<div class="field-row"><div class="field"><label for="d${id}-times-attended">Previous NATCONs attended</label><input id="d${id}-times-attended" data-field="times_attended" type="number" min="0" max="99" step="1" value="0" required></div><div class="field"><label for="d${id}-calling-line">Calling line <span class="muted">(Optional)</span></label><input id="d${id}-calling-line" data-field="calling_line" type="tel" placeholder="Phone number"></div></div>
<div class="field-row delegate-card-wrapper" style="display:none"><div class="field"><label for="d${id}-delegate-card">TAA Delegate ID <span class="muted">(Required if already paid)</span></label><input id="d${id}-delegate-card" data-field="delegate_card_id" maxlength="50" autocomplete="off" aria-describedby="d${id}-delegate-card-feedback" placeholder="TAA/NC/REFORMATION/001"><p id="d${id}-delegate-card-feedback" class="field-feedback">Format: TAA/NC/REFORMATION/001</p></div></div>`;
    
    fieldset.querySelector('.remove-delegate, .copy-contact')?.addEventListener('click', e => {
      if (e.target.classList.contains('copy-contact')) { 
          fieldset.querySelector('[data-field="name"]').value = $('payer-name').value; 
          fieldset.querySelector('[data-field="email"]').value = $('payer-email').value; 
          fieldset.querySelector('[data-field="whatsapp"]').value = $('payer-phone').value; 
      } else { 
          fieldset.remove(); updateTotal(); $('add-delegate').disabled = false; 
      }
    });

    const didInput = fieldset.querySelector('[data-field="delegate_card_id"]');
    didInput.addEventListener('input', () => updateDelegateIdFeedback(didInput));

    $('delegates').append(fieldset); updateTotal(); $('add-delegate').disabled = $('delegates').children.length >= 50;
    
    setTimeout(() => { fieldset.style.opacity = '1'; fieldset.style.transform = 'translateY(0)'; }, 50);
    togglePaymentLogic();
  }

  function credentials() { return {reference:order.reference,token:order.access_token}; }
  function secureLink() { const url = new URL('./', location.href); if (event.event_id) url.searchParams.set('event_id',event.event_id); url.hash = new URLSearchParams(credentials()).toString(); return url.href; }
  
  function renderOrder(next) {
    order = {...order,...next};
    $('registration-form').hidden = true; $('order-panel').hidden = false;
    const paid = order.status === 'paid' || order.status === 'awaiting_review';
    const labels = {pending:'Payment pending',awaiting_review:'Transfer under review',paid:'Payment confirmed',cancelled:'Registration cancelled',refunded:'Payment refunded'};
    $('order-content').innerHTML = `<span class="status-pill">${escape(labels[order.status] || order.status)}</span><p class="order-label">REGISTRATION REFERENCE</p><h3 class="reference">${escape(order.reference)}</h3><p>${paid ? 'Your payment is confirmed or under review. Open and save each delegate’s ticket before travelling.' : 'Your registration is saved. Tickets become available after payment is confirmed.'}</p><div class="form-total"><span>Registration amount</span><strong>${money(order.amount_kobo)}</strong></div><div class="notice">Keep your secure registration link private. It gives access to your registration and tickets.</div><button class="button secondary full" type="button" id="copy-link">Copy secure registration link</button><p id="order-message" class="notice" role="status" hidden></p><div class="order-actions">${!paid && !['cancelled','refunded'].includes(order.status) ? `${event.payment_enabled && order.status !== 'awaiting_review' ? '<button type="button" class="button full" id="pay-now">Pay securely with Paystack →</button>' : ''}<button type="button" class="button secondary full" id="refresh-order">Check payment status</button>` : ''}</div><div>${(order.delegates || []).map(delegate => `<div class="order-delegate"><strong>${escape(delegate.name)}</strong>${paid && delegate.ticket_token ? `<a class="text-link" href="ticket.php#${encodeURIComponent(delegate.ticket_token)}">Open ticket →</a>` : '<span class="muted">Ticket pending</span>'}</div>`).join('')}</div><p class="muted" style="margin-top:24px"><a href="./#register">Start a separate registration</a></p>`;
    $('copy-link').onclick = async () => { try { await navigator.clipboard.writeText(secureLink()); notice('order-message','Secure link copied. Save it somewhere private.'); } catch (_) { notice('order-message',`Save this private link: ${secureLink()}`); } };
    $('pay-now')?.addEventListener('click', async e => { e.target.disabled = true; try { const result = await api('payment_initialize', credentials()); const url = new URL(result.authorization_url); if (url.protocol !== 'https:' || !(url.hostname === 'checkout.paystack.com' || url.hostname.endsWith('.paystack.com'))) throw new Error('The payment provider returned an unexpected address. Contact the team.'); location.assign(url.href); } catch (error) { notice('order-message',error.message,true); e.target.disabled = false; } });
    $('refresh-order')?.addEventListener('click', async e => { e.target.disabled = true; try { renderOrder(await api('payment_verify',credentials(),'GET')); } catch (error) { notice('order-message',error.message,true); e.target.disabled = false; } });
  }

  async function start() {
    if (!$('registration-form')) return;
    
    // Step navigation
    $('step-next').addEventListener('click', () => {
        const err = validateStep(currentStep);
        if(err) return notice('service-message', err, true);
        $('service-message').hidden = true;
        currentStep++; updateSteps();
    });
    $('step-prev').addEventListener('click', () => { currentStep--; updateSteps(); });

    addDelegate(); $('add-delegate').onclick = addDelegate;
    
    const modeRadios = document.querySelectorAll('input[name="registration_mode"]');
    if(modeRadios.length) {
        modeRadios.forEach(r => r.addEventListener('change', () => {
            const mode = document.querySelector('input[name="registration_mode"]:checked').value;
            $('add-delegate').style.display = mode === 'group' ? 'block' : 'none';
            if (mode === 'myself') {
                while($('delegates').children.length > 1) $('delegates').lastElementChild.remove();
                const firstDel = $('delegates').firstElementChild;
                if(firstDel) {
                    firstDel.querySelector('[data-field="name"]').value = $('payer-name').value;
                    firstDel.querySelector('[data-field="email"]').value = $('payer-email').value;
                    firstDel.querySelector('[data-field="whatsapp"]').value = $('payer-phone').value;
                }
            } else if (mode === 'someone_else') {
                while($('delegates').children.length > 1) { $('delegates').lastElementChild.remove(); }
            }
            updateTotal();
        }));
    }
        ['payer-name', 'payer-email', 'payer-phone'].forEach(id => $(id).addEventListener('input', () => {
            if(document.querySelector('input[name="registration_mode"]:checked')?.value !== 'myself') return;
            const field = { 'payer-name': 'name', 'payer-email': 'email', 'payer-phone': 'whatsapp' }[id];
            const delegateInput = $('delegates').firstElementChild?.querySelector(`[data-field="${field}"]`);
            if(delegateInput) delegateInput.value = $(id).value;
        }));

    const paidRadios = document.querySelectorAll('input[name="have_paid"]');
    if(paidRadios.length) {
        paidRadios.forEach(r => r.addEventListener('change', togglePaymentLogic));
    }
    
    document.querySelectorAll('input[name="payment_method"]').forEach(input => input.addEventListener('change', updatePaymentInstructions));

        $('receipt-file').addEventListener('change', () => {
            const file = $('receipt-file').files[0];
            if(!file) return;
            const allowedTypes = ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'];
            if(!allowedTypes.includes(file.type) || file.size > 2500000) {
                $('receipt-file').value = '';
                notice('service-message', 'Choose a PDF, JPEG, PNG, or WebP receipt no larger than 2.5 MB.', true);
            } else {
                $('service-message').hidden = true;
            }
        });

    $('registration-form').addEventListener('submit', async e => { 
        e.preventDefault(); 
                if(currentStep !== 3) return;
                const payerError = validateStep(1);
                if(payerError) return notice('service-message', payerError, true);
        const err = validateStep(2);
        if(err) return notice('service-message', err, true);
                const receipt = $('receipt-file').files[0];
                if(receipt && (receipt.size > 2500000 || !['application/pdf', 'image/jpeg', 'image/png', 'image/webp'].includes(receipt.type))) {
                    return notice('service-message', 'Choose a PDF, JPEG, PNG, or WebP receipt no larger than 2.5 MB.', true);
                }
        
        await submitting(e.target, async () => { 
            try { 
                const data = Object.fromEntries(new FormData(e.target)); 
                data.event_id = String(event.event_id); 
                data.ticket_type_id = selectedTicketTypeId; 
                data.consent = $('privacy-consent').checked;
                data.payment_method = selectedPaymentMethod();
                
                if($('receipt-file').files.length > 0) {
                    data.receipt_url = await convertFileToBase64($('receipt-file').files[0]);
                }
                
                data.delegates = [...$('delegates').children].map(fieldset => Object.fromEntries([...fieldset.querySelectorAll('[data-field]')].map(input => [input.dataset.field,input.value.trim()]))); 
                const result = await api('register',data); 
                order = result; 
                location.hash = new URLSearchParams({reference:result.reference,token:result.access_token}).toString(); 
                renderOrder(result); 
                $('order-panel').scrollIntoView({block:'center'}); 
            } catch (error) { notice('service-message',error.message,true); } 
        }); 
    });
    
    const form=$('registration-form');const eventSelect=document.createElement('select');eventSelect.id='event-select';eventSelect.required=true;const typeSelect=document.createElement('select');typeSelect.id='ticket-type-select';typeSelect.required=true;
    const eventField=document.createElement('div');eventField.className='field';eventField.innerHTML='<label for="event-select">Published event</label>';eventField.append(eventSelect);
    const typeField=document.createElement('div');typeField.className='field';typeField.innerHTML='<label for="ticket-type-select">Ticket type</label>';typeField.append(typeSelect);
    $('step-1').insertBefore(typeField, $('step-1').firstChild);
    $('step-1').insertBefore(eventField, $('step-1').firstChild);

    async function loadEvent(eventId){event=await api('event',{event_id:eventId},'GET');const types=event.ticket_types||[];typeSelect.replaceChildren(...types.map(type=>{const option=document.createElement('option');option.value=type.typeid;option.textContent=`${type.ticket_type} · ${money(Math.round(Number(type.ticket_price)*100))}${Number(type.remainTicket)<99999?` · ${type.remainTicket} left`:''}`;option.disabled=Number(type.remainTicket)<1;return option;}));selectedTicketTypeId=typeSelect.value||'';event.price_kobo=Math.round(Number(types.find(type=>type.typeid===selectedTicketTypeId)?.ticket_price||0)*100);$('price').innerHTML=`${money(event.price_kobo)} <small>/ delegate</small>`;updateTotal();if(!types.length)notice('service-message','Ticket sales are not open for this event yet.',true);else if(!event.payment_enabled)notice('service-message','Online card payment is not available yet. You can register and submit a bank transfer for finance review.');else $('service-message').hidden=true;}
    try { const events=await api('public_events',{},'GET');const primary=await api('event',{},'GET');const params=new URLSearchParams(location.search);const wanted=params.get('event_id')||params.get('event')||String(primary.event_id);eventSelect.replaceChildren(...events.map(item=>{const option=document.createElement('option');option.value=item.event_id;option.textContent=item.event_title;option.selected=item.event_id===wanted;return option;}));if(events.length){await loadEvent(eventSelect.value);eventSelect.addEventListener('change',()=>loadEvent(eventSelect.value).catch(error=>notice('service-message',error.message,true)));typeSelect.addEventListener('change',()=>{selectedTicketTypeId=typeSelect.value;const type=event.ticket_types.find(item=>item.typeid===selectedTicketTypeId);event.price_kobo=Math.round(Number(type?.ticket_price||0)*100);$('price').innerHTML=`${money(event.price_kobo)} <small>/ delegate</small>`;updateTotal();});}else notice('service-message','No published events are currently open for registration.',true); } catch (error) { notice('service-message',error.message,true); }
    const params = new URLSearchParams(location.hash.slice(1)); const query = new URLSearchParams(location.search);
    const reference = params.get('reference') || params.get('order') || query.get('reference'); const token = params.get('token') || query.get('token');
    if (reference && token) { order = {reference,access_token:token}; history.replaceState(null,'',`${location.pathname}#${new URLSearchParams({reference,token})}`); try { renderOrder(await api(query.has('trxref') || query.has('reference') ? 'payment_verify' : 'order',{reference,token},'GET')); $('register').scrollIntoView(); } catch (error) { notice('registration-message',error.message,true); } }
  }
    window.NatconUI = {money,escape,api,isDelegateIdFormatValid:validDelegateId};
    setupRevealAnimations();
  start();
  if ('serviceWorker' in navigator) navigator.serviceWorker.register('sw.js').catch(() => {});
})();
