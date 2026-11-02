import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["query", "household", "empty"]

  connect() {
    this.filter()
  }

  filter() {
    const query = this.queryTarget.value.trim().toLowerCase()
    let matches = 0

    this.householdTargets.forEach(household => {
      household.hidden = !household.dataset.householdName.toLowerCase().includes(query)
      if (!household.hidden) matches++
    })

    this.emptyTarget.hidden = matches > 0
  }
}
