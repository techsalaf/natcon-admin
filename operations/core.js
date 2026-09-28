(function (root, factory) {
  const core = factory();
  if (typeof module === 'object' && module.exports) module.exports = core;
  else root.NatconOperations = core;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
  'use strict';
  const financeRoles = new Set(['admin', 'finance']);
  function canFinance(user) { return Boolean(user && financeRoles.has(user.role)); }
  function canCheckin(user) { return Boolean(user && ['admin', 'registrar'].includes(user.role)); }
  function nairaToKobo(input) {
    const value = String(input || '').trim();
    if (!/^\d{1,10}(?:\.\d{1,2})?$/.test(value)) throw new Error('Enter the exact credited amount in naira, with up to two decimal places.');
    const [whole, fraction = ''] = value.split('.');
    const amount = Number(whole) * 100 + Number(fraction.padEnd(2, '0'));
    if (amount < 1 || !Number.isSafeInteger(amount)) throw new Error('Enter a valid positive credited amount.');
    return amount;
  }
  function ticketToken(input) {
    const value = String(input || '').trim();
    if (!value) throw new Error('Enter the ticket code first.');
    let token = value;
    if (/^https?:\/\//i.test(value)) {
      const url = new URL(value);
      token = url.searchParams.get('token') || url.searchParams.get('ticket') || '';
      if (!token) throw new Error('This link does not contain a ticket code.');
    }
    if (!/^[a-zA-Z0-9_-]{8,256}$/.test(token)) throw new Error('This ticket code is not valid. Check the code printed on the ticket.');
    return token;
  }
  function money(kobo) { return new Intl.NumberFormat('en-NG', { style: 'currency', currency: 'NGN', maximumFractionDigits: 0 }).format(Number(kobo || 0) / 100); }
  function dateTime(value) {
    if (!value) return 'Not recorded';
    // API stores UTC timestamps without offset; display explicitly in conference time.
    const normalized = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/.test(value) ? value.replace(' ', 'T') + 'Z' : value;
    const date = new Date(normalized);
    return Number.isNaN(date.getTime()) ? String(value) : new Intl.DateTimeFormat('en-NG', { timeZone: 'Africa/Lagos', dateStyle: 'medium', timeStyle: 'short' }).format(date) + ' WAT';
  }
  function approvalNote(value) {
    const note = String(value || '').trim();
    if (note.length < 10 || note.length > 1000) throw new Error('Add a reconciliation note of 10–1,000 characters with the bank transaction reference.');
    return note;
  }
  class Api {
    constructor(url, fetcher) { this.url = url; this.fetcher = fetcher; this.csrf = ''; }
    async request(action, body, query) {
      const params = new URLSearchParams({ action, ...(query || {}) });
      const options = { credentials: 'same-origin', cache: 'no-store', headers: { Accept: 'application/json' } };
      if (body !== undefined) {
        options.method = 'POST'; options.headers['Content-Type'] = 'application/json';
        options.headers['X-CSRF-Token'] = this.csrf; options.body = JSON.stringify(body);
      }
      let response;
      try { response = await this.fetcher(this.url + '?' + params, options); }
      catch (_) { throw new Error('Connection failed. Check your network, then try again.'); }
      let payload;
      try { payload = await response.json(); }
      catch (_) { throw new Error('The server returned an unexpected response. Contact the technical team.'); }
      if (!response.ok || !payload.ok) {
        const error = new Error(typeof payload.error === 'string' ? payload.error : payload.error?.message || 'The request could not be completed.');
        error.status = response.status; error.code = payload.code || payload.error?.code; error.data = payload.data; throw error;
      }
      if (payload.data?.csrf) this.csrf = payload.data.csrf;
      return payload.data;
    }
  }
  return { canFinance, canCheckin, ticketToken, money, dateTime, approvalNote, nairaToKobo, Api };
});
