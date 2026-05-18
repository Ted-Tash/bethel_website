import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]

  connect() {
    this.index = 0
    this.interval = setInterval(() => this.next(), 5000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  next() {
    this.slideTargets[this.index].classList.replace("opacity-100", "opacity-0")
    this.index = (this.index + 1) % this.slideTargets.length
    this.slideTargets[this.index].classList.replace("opacity-0", "opacity-100")
  }
}
