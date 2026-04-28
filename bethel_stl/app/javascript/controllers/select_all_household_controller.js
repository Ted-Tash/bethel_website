import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkboxes"]

  toggleAll(event) {
    const container = this.checkboxesTarget
    const checkboxes = container.querySelectorAll("input[type='checkbox']")
    const allChecked = Array.from(checkboxes).every(cb => cb.checked)

    checkboxes.forEach(cb => cb.checked = !allChecked)

    event.currentTarget.textContent = allChecked ? "select all" : "deselect all"
  }
}
