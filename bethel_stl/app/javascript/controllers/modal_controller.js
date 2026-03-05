import { Controller } from "@hotwired/stimulus"

// Manages native <dialog> elements for modals and slide-out panels.
//
// Usage (trigger button - static URL):
//   <button data-controller="modal"
//           data-action="click->modal#open"
//           data-modal-target-param="my_slideout_id">
//     Open
//   </button>
//
// Usage (trigger button - dynamic URL, e.g. edit):
//   <tr data-controller="modal"
//       data-action="click->modal#open"
//       data-modal-target-param="edit_slideout"
//       data-base-url="/admin/households/1/edit?slideout=true">
//     ...
//   </tr>
//
// Usage (dialog element):
//   <dialog id="my_slideout_id" class="modal modal-end"
//           data-controller="modal"
//           data-action="close->modal#handleClose">
//     ...
//   </dialog>

export default class extends Controller {
  static values = {
    autoFocus: { type: Boolean, default: true }
  }

  connect() {
    if (this.element instanceof HTMLDialogElement) {
      // If nested inside another dialog, move to body level
      const parentDialog = this.element.parentElement?.closest("dialog")
      if (parentDialog) {
        document.body.appendChild(this.element)
      }
    }
  }

  open(event) {
    // Don't open modal when clicking links or buttons inside the trigger
    if (event.target.closest("a, button:not([data-action*='modal#open'])")) {
      return
    }

    const modal = document.getElementById(event.params.target)
    if (!(modal instanceof HTMLDialogElement)) return

    this.#setFrameUrl(modal, event.currentTarget)

    // Restore turbo-frame src to trigger fresh load
    modal.querySelectorAll("turbo-frame[data-original-src]").forEach(frame => {
      frame.src = frame.dataset.originalSrc
      if (typeof frame.reload === "function") {
        frame.reload()
      }
    })

    modal.showModal()

    if (this.autoFocusValue) {
      requestAnimationFrame(() => {
        const firstInput = modal.querySelector('input:not([type="hidden"]), textarea, select')
        if (firstInput) firstInput.focus()
      })
    }
  }

  close(event) {
    const dialog = this.element.closest("dialog") || this.element
    if (dialog instanceof HTMLDialogElement) {
      dialog.close()
    }
  }

  handleClose(event) {
    // Reset turbo frames inside the dialog so they reload fresh next time
    this.element.querySelectorAll("turbo-frame").forEach(frame => {
      if (frame.hasAttribute("src") && !frame.dataset.originalSrc) {
        frame.dataset.originalSrc = frame.src
      }
      frame.removeAttribute("src")
      frame.innerHTML = '<div class="flex justify-center py-8"><span class="loading loading-spinner loading-md"></span></div>'
    })
  }

  // Set turbo-frame src from trigger's data-base-url attribute
  #setFrameUrl(modal, trigger) {
    const baseUrl = trigger.dataset.baseUrl
    if (!baseUrl) return

    const frame = modal.querySelector("turbo-frame")
    if (frame) {
      frame.src = baseUrl
      frame.dataset.originalSrc = baseUrl
    }
  }
}
