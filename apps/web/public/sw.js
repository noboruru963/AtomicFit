<!-- @atomfit/web/public/sw.js
     Service worker for offline + installable PWA (Rule I-09).
     Standard web APIs only. Provides best-effort lock-screen quick-add notification
     where supported (BA-005); otherwise in-app quick-add bar is the mandatory path. -->
const CACHE_NAME = 'atomfit-v1';
const ASSETS = ['/', '/index.html', '/manifest.json', '/logo.svg'];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS)),
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request)),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))),
    ),
  );
});

// Best-effort push/notification for lock-screen quick-add (BA-005).
// Not supported on all browsers (notably iOS); in-app bar remains mandatory.
self.addEventListener('push', (event) => {
  const options = {
    body: 'Quick-add a rep or set',
    icon: '/logo.svg',
    badge: '/logo.svg',
    tag: 'atomfit-quick-add',
    actions: [
      { action: 'add-rep', title: '+1 rep' },
      { action: 'add-set', title: '+1 set' },
    ],
  };
  event.waitUntil(self.registration.showNotification('AtomFit', options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = event.action ? `/?quick=${event.action}` : '/';
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      for (const client of clients) {
        if (client.url.includes(self.location.origin)) {
          return client.focus().then(() => client.navigate(url));
        }
      }
      return self.clients.openWindow(url);
    }),
  );
});
