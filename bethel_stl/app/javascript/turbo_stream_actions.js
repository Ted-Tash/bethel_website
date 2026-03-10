import { Turbo } from "@hotwired/turbo-rails"

// Custom Turbo Stream action: close a native <dialog> by ID
// Usage in .turbo_stream.haml: = turbo_stream_action_tag(:close_dialog, target: "my_dialog_id")
Turbo.StreamActions.close_dialog = function() {
  const dialog = document.getElementById(this.target)
  if (dialog instanceof HTMLDialogElement) {
    dialog.close()
  }
}

// Custom Turbo Stream action: open a native <dialog> by ID, optionally setting a turbo-frame src
// Usage: = turbo_stream_action_tag(:open_dialog, target: "edit_slideout", "frame-url": edit_path)
Turbo.StreamActions.open_dialog = function() {
  const dialog = document.getElementById(this.target)
  if (!(dialog instanceof HTMLDialogElement)) return

  const frameUrl = this.getAttribute("frame-url")
  if (frameUrl) {
    const frame = dialog.querySelector("turbo-frame")
    if (frame) {
      frame.src = frameUrl
      frame.dataset.originalSrc = frameUrl
    }
  }

  dialog.showModal()
}

// Custom Turbo Stream action: reload a turbo-frame from its src
// Usage in .turbo_stream.haml: = turbo_stream_action_tag(:reload_frame, target: "my_frame_id")
Turbo.StreamActions.reload_frame = function() {
  const frame = document.getElementById(this.target)
  if (frame?.reload) {
    frame.reload()
  }
}
