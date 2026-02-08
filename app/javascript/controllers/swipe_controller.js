import { Controller } from "@hotwired/stimulus"
import { visit } from "@hotwired/turbo"

export default class extends Controller {
  static values = {
    prevUrl: String,
    nextUrl: String
  }

  static targets = ["calendar"]

  connect() {
    this.touchStartX = 0
    this.touchStartY = 0
    this.handleBeforeRender = this.slideInNewPage.bind(this)
  }

  touchstart(event) {
    this.touchStartX = event.changedTouches[0].screenX
    this.touchStartY = event.changedTouches[0].screenY
  }

  touchend(event) {
    const deltaX = event.changedTouches[0].screenX - this.touchStartX
    const deltaY = event.changedTouches[0].screenY - this.touchStartY

    if (Math.abs(deltaX) < 50) return
    if (Math.abs(deltaY) > Math.abs(deltaX)) return

    const swipeLeft = deltaX < 0
    const url = swipeLeft ? this.nextUrlValue : this.prevUrlValue
    const outClass = swipeLeft ? "animate-slide-out-left" : "animate-slide-out-right"
    this.slideInClass = swipeLeft ? "animate-slide-in-from-right" : "animate-slide-in-from-left"

    document.addEventListener("turbo:before-render", this.handleBeforeRender, { once: true })

    this.calendarTarget.classList.add(outClass)
    this.calendarTarget.addEventListener("animationend", () => {
      visit(url)
    }, { once: true })
  }

  slideInNewPage(event) {
    const newBody = event.detail.newBody
    const target = newBody.querySelector("[data-swipe-target='calendar']")
    if (target) {
      target.classList.add(this.slideInClass)
      target.addEventListener("animationend", () => {
        target.classList.remove(this.slideInClass)
      }, { once: true })
    }
  }
}
