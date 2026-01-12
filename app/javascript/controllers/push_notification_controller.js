import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    vapidPublicKey: String
  }
  static targets = ["status", "subscribeBtn", "unsubscribeBtn"]

  async connect() {
    if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
      this.updateStatus("Push notifications not supported")
      return
    }

    try {
      const registration = await navigator.serviceWorker.register("/service-worker")
      this.registration = registration
      await this.checkSubscription()
    } catch (e) {
      console.error("Service Worker registration failed:", e)
      this.updateStatus("Service Worker registration failed")
    }
  }

  async checkSubscription() {
    const subscription = await this.registration.pushManager.getSubscription()
    if (subscription) {
      this.showUnsubscribeButton()
      this.updateStatus("Notifications enabled")
    } else {
      this.showSubscribeButton()
      this.updateStatus("Notifications disabled")
    }
  }

  async subscribe() {
    try {
      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        this.updateStatus("Permission denied")
        return
      }

      const subscription = await this.registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidPublicKeyValue)
      })

      await this.saveSubscription(subscription)
      this.showUnsubscribeButton()
      this.updateStatus("Notifications enabled")
    } catch (e) {
      console.error("Subscription failed:", e)
      this.updateStatus("Subscription failed: " + e.message)
    }
  }

  async unsubscribe() {
    try {
      const subscription = await this.registration.pushManager.getSubscription()
      if (subscription) {
        await this.deleteSubscription(subscription)
        await subscription.unsubscribe()
      }
      this.showSubscribeButton()
      this.updateStatus("Notifications disabled")
    } catch (e) {
      console.error("Unsubscribe failed:", e)
    }
  }

  async saveSubscription(subscription) {
    const key = subscription.getKey("p256dh")
    const auth = subscription.getKey("auth")

    const response = await fetch("/push_subscriptions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        endpoint: subscription.endpoint,
        p256dh: btoa(String.fromCharCode(...new Uint8Array(key))),
        auth: btoa(String.fromCharCode(...new Uint8Array(auth)))
      })
    })

    if (!response.ok) {
      throw new Error("Failed to save subscription")
    }
  }

  async deleteSubscription(subscription) {
    await fetch("/push_subscriptions", {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({
        endpoint: subscription.endpoint
      })
    })
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }

  updateStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }

  showSubscribeButton() {
    if (this.hasSubscribeBtnTarget) {
      this.subscribeBtnTarget.classList.remove("hidden")
    }
    if (this.hasUnsubscribeBtnTarget) {
      this.unsubscribeBtnTarget.classList.add("hidden")
    }
  }

  showUnsubscribeButton() {
    if (this.hasSubscribeBtnTarget) {
      this.subscribeBtnTarget.classList.add("hidden")
    }
    if (this.hasUnsubscribeBtnTarget) {
      this.unsubscribeBtnTarget.classList.remove("hidden")
    }
  }
}
