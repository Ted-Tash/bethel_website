import { Controller } from "@hotwired/stimulus"

// Polls the current URL on an interval and replaces the target element.
// Stops polling when the element is disconnected or data-poll-active is removed.
//
// Usage:
//   <div data-controller="poll" data-poll-interval-value="5000">
//     <div data-poll-target="content"> ... </div>
//   </div>
export default class extends Controller {
  static targets = ["content"]
  static values = { interval: { type: Number, default: 5000 } }

  connect() {
    this.timer = setInterval(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async poll() {
    try {
      const response = await fetch(window.location.href, {
        headers: { "Accept": "text/html", "X-Requested-With": "XMLHttpRequest" }
      })
      if (!response.ok) return

      const html = await response.text()
      const doc = new DOMParser().parseFromString(html, "text/html")
      const newContent = doc.querySelector(`[data-poll-target="content"]`)

      if (newContent) {
        this.contentTarget.innerHTML = newContent.innerHTML

        // Stop polling if the new content no longer has the poll controller
        if (!newContent.closest('[data-controller~="poll"]')) {
          clearInterval(this.timer)
        }
      }
    } catch (e) {
      // Network error, skip this poll cycle
    }
  }
}
