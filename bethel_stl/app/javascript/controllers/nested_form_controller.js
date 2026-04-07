import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container", "addButton"]

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.containerTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const fieldset = event.target.closest("[data-nested-form-target='fields']")
    const destroyInput = fieldset.querySelector("input[name*='_destroy']")

    if (destroyInput) {
      destroyInput.value = "1"
      fieldset.style.opacity = "0.35"
      fieldset.style.pointerEvents = "none"
      fieldset.dataset.markedForDestruction = "true"
    } else {
      fieldset.remove()
    }
  }
}
