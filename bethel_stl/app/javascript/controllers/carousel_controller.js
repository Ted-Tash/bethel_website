import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track"]

  scrollLeft() {
    this.trackTarget.scrollBy({ left: -280, behavior: "smooth" })
  }

  scrollRight() {
    this.trackTarget.scrollBy({ left: 280, behavior: "smooth" })
  }
}
