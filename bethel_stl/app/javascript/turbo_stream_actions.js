import { Turbo } from "@hotwired/turbo-rails"

// Custom Turbo Stream action: close a native <dialog> by ID
// Usage in .turbo_stream.haml: = turbo_stream_action_tag(:close_dialog, target: "my_dialog_id")
Turbo.StreamActions.close_dialog = function() {
  const dialog = document.getElementById(this.target)
  if (dialog instanceof HTMLDialogElement) {
    dialog.close()
  }
}

// Custom Turbo Stream action: reload a turbo-frame from its src
// Usage in .turbo_stream.haml: = turbo_stream_action_tag(:reload_frame, target: "my_frame_id")
Turbo.StreamActions.reload_frame = function() {
  const frame = document.getElementById(this.target)
  if (frame?.reload) {
    frame.reload()
  }
}
