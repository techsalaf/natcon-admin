'use strict';
const CACHE = 'natcon-static-v5';
const ASSETS = ['assets/style.css','assets/app.js','assets/ticket.js','assets/icon.svg','manifest.webmanifest','offline.html'];
self.addEventListener('install', event => event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(ASSETS))));
self.addEventListener('activate', event => event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith('natcon-static-') && key !== CACHE).map(key => caches.delete(key))))));
self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.origin !== self.location.origin) return;
  const relative = url.pathname.slice(new URL(self.registration.scope).pathname.length);
  // Never cache documents, API responses, bearer links, registration data or QR images.
  if (ASSETS.includes(relative) && !url.search) {
    event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request)));
  } else if (event.request.mode === 'navigate') {
    event.respondWith(fetch(event.request).catch(() => caches.match('offline.html')));
  }
});
