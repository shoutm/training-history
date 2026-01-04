import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "fields", "position", "destroy"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    this.updatePositions()
  }

  remove(event) {
    event.preventDefault()
    const fields = event.target.closest("[data-nested-form-target='fields']")

    // If this is a persisted record, mark it for destruction
    const destroyField = fields.querySelector("[data-nested-form-target='destroy']")
    if (destroyField) {
      destroyField.value = "1"
      fields.style.display = "none"
    } else {
      // If it's a new record, just remove it from the DOM
      fields.remove()
    }
    this.updatePositions()
  }

  updatePositions() {
    const visibleFields = this.containerTarget.querySelectorAll("[data-nested-form-target='fields']:not([style*='display: none'])")
    visibleFields.forEach((field, index) => {
      const positionInput = field.querySelector("[data-nested-form-target='position']")
      if (positionInput) {
        positionInput.value = index
      }
    })
  }
}
