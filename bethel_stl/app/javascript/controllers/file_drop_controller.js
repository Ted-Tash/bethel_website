import { Controller } from "@hotwired/stimulus"

// Drag-and-drop file upload controller.
//
// Usage:
//   <div data-controller="file-drop"
//        data-file-drop-url-value="/admin/recordings/1/documents"
//        data-file-drop-frame-id-value="recording_documents"
//        data-file-drop-param-name-value="document[file]">
//     <input type="file" multiple data-file-drop-target="input" class="hidden">
//     <div data-file-drop-target="overlay" class="hidden">Drop files here</div>
//   </div>

export default class extends Controller {
  static targets = ["input", "overlay", "status"]
  static values = {
    url: String,
    frameId: String,
    paramName: { type: String, default: "document[file]" }
  }

  connect() {
    this.dragCounter = 0
    this.boundDragEnter = this.dragEnter.bind(this)
    this.boundDragOver = this.dragOver.bind(this)
    this.boundDragLeave = this.dragLeave.bind(this)
    this.boundDrop = this.drop.bind(this)

    this.element.addEventListener("dragenter", this.boundDragEnter)
    this.element.addEventListener("dragover", this.boundDragOver)
    this.element.addEventListener("dragleave", this.boundDragLeave)
    this.element.addEventListener("drop", this.boundDrop)
  }

  disconnect() {
    this.element.removeEventListener("dragenter", this.boundDragEnter)
    this.element.removeEventListener("dragover", this.boundDragOver)
    this.element.removeEventListener("dragleave", this.boundDragLeave)
    this.element.removeEventListener("drop", this.boundDrop)
  }

  browse() {
    this.inputTarget.click()
  }

  inputChanged() {
    const files = this.inputTarget.files
    if (files.length > 0) {
      this.uploadFiles(files)
    }
    this.inputTarget.value = ""
  }

  dragEnter(event) {
    event.preventDefault()
    this.dragCounter++
    this.showOverlay()
  }

  dragOver(event) {
    event.preventDefault()
  }

  dragLeave(event) {
    event.preventDefault()
    this.dragCounter--
    if (this.dragCounter === 0) {
      this.hideOverlay()
    }
  }

  drop(event) {
    event.preventDefault()
    this.dragCounter = 0
    this.hideOverlay()

    const files = event.dataTransfer.files
    if (files.length > 0) {
      this.uploadFiles(files)
    }
  }

  async uploadFiles(files) {
    const total = files.length
    let uploaded = 0
    let failed = 0

    this.showStatus(`Uploading 0 of ${total}...`)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    for (const file of files) {
      try {
        const formData = new FormData()
        formData.append(this.paramNameValue, file)

        const response = await fetch(this.urlValue, {
          method: "POST",
          headers: {
            "X-CSRF-Token": csrfToken,
            "Accept": "application/json"
          },
          body: formData
        })

        if (response.ok) {
          uploaded++
        } else {
          failed++
        }
      } catch (error) {
        failed++
      }

      this.showStatus(`Uploading ${uploaded + failed} of ${total}...`)
    }

    this.hideStatus()
    this.reloadFrame()

    if (failed > 0) {
      this.showToast(`${uploaded} uploaded, ${failed} failed`, "error")
    } else {
      this.showToast(`${uploaded} ${uploaded === 1 ? "file" : "files"} uploaded`, "success")
    }
  }

  reloadFrame() {
    const frame = document.getElementById(this.frameIdValue)
    if (frame?.reload) {
      frame.reload()
    }
  }

  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
  }

  hideOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
  }

  showStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove("hidden")
    }
  }

  hideStatus() {
    if (this.hasStatusTarget) {
      this.statusTarget.classList.add("hidden")
    }
  }

  showToast(message, type) {
    const toast = document.createElement("div")
    toast.className = `alert alert-${type === "error" ? "error" : "success"} fixed bottom-4 right-4 z-50 w-auto max-w-sm shadow-lg`
    toast.textContent = message
    document.body.appendChild(toast)
    setTimeout(() => toast.remove(), 3000)
  }
}
