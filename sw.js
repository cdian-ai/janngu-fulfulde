/* Janngu Fulfulde 1 — service worker
   2026-09-01, first version, shipped with v179.

   What this is for: the course is used on phones by families in London, often
   on the move. Without this, every visit re-downloads the page and re-fetches
   each clip, and a dead spot means a lesson stops. With it, the page and every
   clip that has been played sit on the device.

   Two rules, and they are different on purpose:

   The page itself is fetched from the network first. A new build should reach a
   family the next time they open it, not weeks later — and the cached copy is
   there as the fallback the moment the network is not.

   Audio is served from the cache first. A clip never changes once recorded, so
   there is nothing to be gained by asking again, and everything to be gained by
   answering instantly and offline. Clips are cached as they are played rather
   than all at once: 270 files on a first visit over mobile data would be a rude
   thing to do to somebody, and most children will never touch every one.
*/

var VERSION = "janngu-v179-2026-09-01";
var SHELL   = "shell-" + VERSION;
var MEDIA   = "media-" + VERSION;

var SHELL_FILES = [
  "./",
  "index.html",
  "manifest.webmanifest",
  "icon-192.png",
  "icon-512.png"
];

self.addEventListener("install", function (e) {
  // addAll fails as a whole if any one file 404s, so each is added on its own
  // and a miss is allowed to pass. A missing icon should never block install.
  e.waitUntil(
    caches.open(SHELL).then(function (c) {
      return Promise.all(SHELL_FILES.map(function (f) {
        return c.add(f).catch(function () {});
      }));
    }).then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.map(function (k) {
        if (k !== SHELL && k !== MEDIA) return caches.delete(k);
      }));
    }).then(function () { return self.clients.claim(); })
  );
});

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET") return;

  var url;
  try { url = new URL(req.url); } catch (err) { return; }
  if (url.origin !== self.location.origin) return;

  var isMedia = /\.(m4a|mp3|ogg|wav|aac)$/i.test(url.pathname);

  if (isMedia) {
    // cache first — a recording does not change
    e.respondWith(
      caches.match(req).then(function (hit) {
        if (hit) return hit;
        return fetch(req).then(function (res) {
          if (res && res.ok) {
            var copy = res.clone();
            caches.open(MEDIA).then(function (c) { c.put(req, copy); });
          }
          return res;
        }).catch(function () {
          // no network and never played before: let the course fall back to
          // its own quiet mode rather than throwing
          return new Response("", { status: 504, statusText: "offline" });
        });
      })
    );
    return;
  }

  // network first for everything else, so a new build arrives promptly
  e.respondWith(
    fetch(req).then(function (res) {
      if (res && res.ok) {
        var copy = res.clone();
        caches.open(SHELL).then(function (c) { c.put(req, copy); });
      }
      return res;
    }).catch(function () {
      return caches.match(req).then(function (hit) {
        return hit || caches.match("index.html") || caches.match("./");
      });
    })
  );
});
