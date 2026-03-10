import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "field"]

  extract() {
    const file = this.inputTarget.files[0]
    if (!file) return

    console.log("[audio-duration] File selected:", file.name, file.type)

    const url = URL.createObjectURL(file)
    const audio = new Audio()
    audio.preload = "metadata"

    audio.addEventListener("loadedmetadata", () => {
      console.log("[audio-duration] Duration detected:", audio.duration)
      this.fieldTarget.value = Math.round(audio.duration)
      URL.revokeObjectURL(url)
    })

    audio.addEventListener("error", (e) => {
      console.error("[audio-duration] Error loading audio:", e)
      URL.revokeObjectURL(url)
    })

    audio.src = url
  }
}
