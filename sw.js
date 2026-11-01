const CACHE_NAME = 'herzenssache-v2';
const BASE_PATH = new URL('./', self.location).pathname;
const APP_FILES = [
  BASE_PATH,
  `${BASE_PATH}index.html`,
  `${BASE_PATH}manifest.webmanifest`,
  `${BASE_PATH}details.js`,
  `${BASE_PATH}selfcare.js`,
  `${BASE_PATH}icons/icon-192.png`,
  `${BASE_PATH}icons/icon-512.png`
];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(APP_FILES)));
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET' || new URL(request.url).origin !== self.location.origin) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE_NAME);
    if (request.mode === 'navigate') {
      try {
        const response = await fetch(request);
        if (response.ok) await cache.put(BASE_PATH, response.clone());
        return response;
      } catch (error) {
        return (await cache.match(BASE_PATH)) || (await cache.match(`${BASE_PATH}index.html`));
      }
    }
    const cached = await cache.match(request, {ignoreSearch: true});
    if (cached) return cached;
    try {
      const response = await fetch(request);
      if (response.ok) cache.put(request, response.clone());
      return response;
    } catch (error) {
      if (request.mode === 'navigate') {
        return (await cache.match(BASE_PATH)) || (await cache.match(`${BASE_PATH}index.html`));
      }
      return Response.error();
    }
  })());
});

