// Semiose: busca a versão mais nova quando tem internet e usa a cópia guardada quando não tem.
// Também dá os avisos do dia onde o navegador deixa (Android com o app instalado, via periodicSync).
const CACHE = 'semiose-v5';
// ajustes que o app deixa para cá (o service worker não lê o localStorage)
const CFG = 'semiose-cfg';
const ASSETS = ['./', './index.html', './manifest.webmanifest', './icons/icon-180.png', './icons/icon-192.png', './icons/icon-512.png'];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE && k !== CFG).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // fontes do Google: guarda uma vez e reaproveita
  if (url.hostname === 'fonts.googleapis.com' || url.hostname === 'fonts.gstatic.com') {
    e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(req, copy));
      return res;
    })));
    return;
  }

  if (url.origin !== location.origin) return;
  // o feed vem com ?t= para furar cache; offline, serve o último guardado
  const key = /\/data\/[^/]+\.json$/.test(url.pathname) ? new Request(url.origin + url.pathname) : req;
  e.respondWith(
    fetch(req)
      .then(res => {
        if (res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(key, copy));
        }
        return res;
      })
      .catch(() => caches.match(key).then(hit => hit || caches.match('./index.html')))
  );
});

// ---------- aviso do dia ----------
const pad = n => String(n).padStart(2, '0');
// o dia vira às 4h, como no app
const dayKey = (t = Date.now()) => { const d = new Date(t - 4 * 3600e3); return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`; };
async function readCfg() {
  const hit = await caches.open(CFG).then(c => c.match('cfg'));
  return hit ? hit.json() : null;
}
async function writeCfg(cfg) {
  const c = await caches.open(CFG);
  await c.put('cfg', new Response(JSON.stringify(cfg), { headers: { 'Content-Type': 'application/json' } }));
}
async function dailyNotice() {
  const cfg = await readCfg();
  if (!cfg || !cfg.on) return;
  const now = new Date(), today = dayKey();
  // dia novo: o número no ícone volta para a meta inteira
  if (cfg.day !== today && self.navigator.setAppBadge) self.navigator.setAppBadge(cfg.goal).catch(() => {});
  const [h, m] = String(cfg.hour || '08:00').split(':').map(Number);
  if (cfg.last === today || now.getHours() * 60 + now.getMinutes() < h * 60 + m) return;
  let fresh = 0;
  try {
    const res = await fetch('data/feed.json?t=' + Date.now(), { cache: 'no-store' });
    const feed = await res.json();
    fresh = (feed.items || []).filter(it => Date.parse(it.fs || it.at) > (cfg.seen || 0)).length;
    caches.open(CACHE).then(c => c.put(new Request(new URL('data/feed.json', self.registration.scope).href), new Response(JSON.stringify(feed), { headers: { 'Content-Type': 'application/json' } })));
  } catch (e) {}
  const hi = cfg.name ? `${cfg.name}, sua` : 'Sua';
  await self.registration.showNotification('Hora da leitura', {
    body: `${hi} seleção de hoje está pronta: ${cfg.goal} ${cfg.goal === 1 ? 'artigo' : 'artigos'}.${fresh ? ` Chegaram ${fresh} novos desde a sua última visita.` : ''}`,
    icon: 'icons/icon-192.png',
    badge: 'icons/badge-96.png',
    tag: 'semiose-dia'
  });
  cfg.last = today;
  await writeCfg(cfg);
}
self.addEventListener('periodicsync', e => {
  if (e.tag === 'semiose-dia') e.waitUntil(dailyNotice());
});
self.addEventListener('notificationclick', e => {
  e.notification.close();
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
    const open = list.find(c => c.url.startsWith(self.registration.scope));
    return open ? open.focus() : self.clients.openWindow('./');
  }));
});
