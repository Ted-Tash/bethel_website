import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scheduledAt", "sendNowBtn", "scheduleBtn", "channel", "subjectContainer", "subject", "smsHint"]

  connect() {
    this.toggle()
    this.channelChanged()
  }

  channelChanged() {
    const email = this.channelTarget.value === "email"
    this.subjectContainerTarget.hidden = !email
    this.subjectTarget.required = email
    this.smsHintTarget.hidden = email
  }

  toggle() {
    const hasDate = this.scheduledAtTarget.value !== ""

    this.sendNowBtnTarget.disabled = hasDate
    this.sendNowBtnTarget.classList.toggle("opacity-50", hasDate)

    this.scheduleBtnTarget.disabled = !hasDate
    this.scheduleBtnTarget.classList.toggle("opacity-50", !hasDate)
  }
}
