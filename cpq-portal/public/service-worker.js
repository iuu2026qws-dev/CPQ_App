// CPQ Mobile PWA Service Worker（S19.7）
const CACHE_NAME = 'cpq-mobile-v1.5.0'
const STATIC_ASSETS = [
  '/mobile/home',
  '/',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
]

const API_CACHE_NAME = 'cpq-api-v1'

// 安装：预缓存静态资源
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch(() => {
        // 部分资源可能不存在，继续
      })
    }).then(() => self.skipWaiting())
  )
})

// 激活：清理旧缓存
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter(k => k !== CACHE_NAME && k !== API_CACHE_NAME)
          .map(k => caches.delete(k))
      )
    }).then(() => self.clients.claim())
  )
})

// 网络优先策略（API请求直接走网络，失败时返回离线提示）
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url)

  // API 请求：网络优先，失败返回离线 JSON
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(event.request).catch(() => {
        return new Response(
          JSON.stringify({ code: 500, msg: '您当前处于离线状态' }),
          { headers: { 'Content-Type': 'application/json' } }
        )
      })
    )
    return
  }

  // 静态资源：缓存优先
  if (url.pathname.match(/\.(js|css|png|svg|ico|woff2?)$/)) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        return cached || fetch(event.request).then((response) => {
          const clone = response.clone()
          caches.open(CACHE_NAME).then((cache) => cache.put(event.request, clone))
          return response
        })
      })
    )
    return
  }

  // HTML 页面：网络优先，失败返回离线首页
  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match('/mobile/home').then((cached) => {
        return cached || new Response('离线状态', { status: 503 })
      })
    })
  )
})

// 推送通知
self.addEventListener('push', (event) => {
  const data = event.data?.json() || {}
  const options = {
    body: data.body || '您有新的待审批项',
    icon: '/icons/icon-192.png',
    badge: '/icons/icon-192.png',
    vibrate: [200, 100, 200],
    data: { url: data.url || '/mobile/approval' },
    tag: data.tag || 'cpq-approval',
    renotify: true,
  }
  event.waitUntil(
    self.registration.showNotification(data.title || 'CPQ 提醒', options)
  )
})

// 通知点击打开页面
self.addEventListener('notificationclick', (event) => {
  event.notification.close()
  const url = event.notification.data?.url || '/mobile/home'
  event.waitUntil(
    self.clients.matchAll({ type: 'window' }).then((clients) => {
      for (const client of clients) {
        if (client.url.includes(url) && 'focus' in client) {
          return client.focus()
        }
      }
      if (self.clients.openWindow) {
        return self.clients.openWindow(url)
      }
    })
  )
})
