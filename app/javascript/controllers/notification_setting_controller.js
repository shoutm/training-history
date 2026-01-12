import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timeInput", "hiddenInput"]

  connect() {
    // Convert UTC time from server to local time for display
    const utcTime = this.hiddenInputTarget.value
    if (utcTime) {
      this.timeInputTarget.value = this.utcToLocal(utcTime)
    }
  }

  // Called when time input changes
  updateHidden() {
    const localTime = this.timeInputTarget.value
    if (localTime) {
      this.hiddenInputTarget.value = this.localToUtc(localTime)
    }
  }

  // Convert "HH:MM" local time to UTC "HH:MM"
  localToUtc(localTime) {
    const [hours, minutes] = localTime.split(":").map(Number)
    const now = new Date()
    now.setHours(hours, minutes, 0, 0)
    const utcHours = now.getUTCHours().toString().padStart(2, "0")
    const utcMinutes = now.getUTCMinutes().toString().padStart(2, "0")
    return `${utcHours}:${utcMinutes}`
  }

  // Convert "HH:MM" UTC time to local "HH:MM"
  utcToLocal(utcTime) {
    const [hours, minutes] = utcTime.split(":").map(Number)
    const now = new Date()
    now.setUTCHours(hours, minutes, 0, 0)
    const localHours = now.getHours().toString().padStart(2, "0")
    const localMinutes = now.getMinutes().toString().padStart(2, "0")
    return `${localHours}:${localMinutes}`
  }
}
