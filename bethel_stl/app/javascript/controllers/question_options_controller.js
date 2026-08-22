import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["type", "section", "option"]

  connect() {
    this.toggle()
  }

  optionTargetConnected(option) {
    option.disabled = !this.choiceType
    option.required = this.choiceType
  }

  toggle() {
    const visible = this.choiceType
    this.sectionTarget.classList.toggle("hidden", !visible)

    this.optionTargets.forEach((option) => {
      option.disabled = !visible
      option.required = visible
    })
  }

  get choiceType() {
    return ["single_choice", "multiple_choice"].includes(this.typeTarget.value)
  }
}
