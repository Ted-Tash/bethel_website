import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "status"]
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      dataIdAttr: "data-question-id",
      handle: "[data-sortable-handle]",
      ghostClass: "opacity-40",
      chosenClass: "bg-base-200",
      onStart: () => {
        this.originalOrder = this.sortable.toArray()
      },
      onEnd: () => this.persist()
    })
  }

  disconnect() {
    this.sortable?.destroy()
  }

  async persist() {
    const questionIds = this.sortable.toArray()
    this.setStatus("Saving order…")

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ question_ids: questionIds })
      })

      if (!response.ok) throw new Error(`Request failed with ${response.status}`)

      this.setStatus("Order saved")
    } catch (error) {
      if (this.originalOrder) this.sortable.sort(this.originalOrder)
      this.setStatus("Could not save order. Please try again.", true)
      console.error("Unable to reorder registration questions", error)
    }
  }

  setStatus(message, error = false) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent = message
    this.statusTarget.classList.toggle("text-error", error)
  }
}
