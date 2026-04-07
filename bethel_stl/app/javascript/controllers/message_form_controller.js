import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scheduledAt", "sendNowBtn", "scheduleBtn"]

  connect() {
    this.toggle()
  }

  toggle() {
    const hasDate = this.scheduledAtTarget.value !== ""

    this.sendNowBtnTarget.disabled = hasDate
    this.sendNowBtnTarget.classList.toggle("opacity-50", hasDate)

    this.scheduleBtnTarget.disabled = !hasDate
    this.scheduleBtnTarget.classList.toggle("opacity-50", !hasDate)
  }
}
