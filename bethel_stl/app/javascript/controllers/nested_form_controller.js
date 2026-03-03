import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container", "addButton"]
  static values = { max: { type: Number, default: 2 } }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    this.updateAddButton()
  }

  remove(event) {
    event.preventDefault()
    const fieldset = event.target.closest("[data-nested-form-target='fields']")
    const destroyInput = fieldset.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      destroyInput.value = "1"
      fieldset.style.display = "none"
    } else {
      fieldset.remove()
    }
    this.updateAddButton()
  }

  updateAddButton() {
    const visible = this.visibleFieldsCount()
    if (this.hasAddButtonTarget) {
      this.addButtonTarget.disabled = visible >= this.maxValue
    }
  }

  visibleFieldsCount() {
    return this.containerTarget.querySelectorAll("[data-nested-form-target='fields']:not([style*='display: none'])").length
  }
}
