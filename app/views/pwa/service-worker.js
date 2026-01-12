// Service Worker for Push Notifications

console.log("Service Worker loaded")

self.addEventListener("push", (event) => {
  console.log("Push event received:", event)

  let data = {}
  try {
    data = event.data ? event.data.json() : {}
  } catch (e) {
    console.error("Failed to parse push data:", e)
    data = { title: "Training History", body: "Time to work out!" }
  }

  const title = data.title || "Training History"
  const options = {
    body: data.body || "Time to work out!",
    icon: "/icon.png",
    badge: "/icon.png",
    data: {
      path: data.path || "/"
    }
  }

  console.log("Showing notification:", title, options)
  event.waitUntil(self.registration.showNotification(title, options))
})

self.addEventListener("notificationclick", (event) => {
  event.notification.close()
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      for (const client of clientList) {
        const clientPath = (new URL(client.url)).pathname
        if (clientPath === event.notification.data.path && "focus" in client) {
          return client.focus()
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(event.notification.data.path)
      }
    })
  )
})
