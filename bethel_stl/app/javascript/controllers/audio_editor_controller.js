import { Controller } from "@hotwired/stimulus"
import WaveSurfer from "wavesurfer.js"
import RegionsPlugin from "wavesurfer-regions"

export default class extends Controller {
  static targets = [
    "waveform", "currentTime", "totalTime",
    "playBtn", "status", "zoomSlider",
    "regionStart", "regionEnd", "regionDuration",
    "regionControls", "regionHint", "saveBtn", "undoBtn",
    "restoreBtn", "speedBtn"
  ]
  static values = {
    audioUrl: String,
    saveUrl: String,
    restoreUrl: String,
    durationUrl: String,
    csrfToken: String,
    hasOriginal: Boolean
  }

  connect() {
    this.history = []
    this.currentBuffer = null
    this.activeRegion = null
    this.isProcessing = false
    this.playbackRate = 1.0

    this.initWaveSurfer()
  }

  disconnect() {
    if (this.wavesurfer) {
      this.wavesurfer.destroy()
    }
  }

  initWaveSurfer() {
    this.regions = RegionsPlugin.create()

    this.wavesurfer = WaveSurfer.create({
      container: this.waveformTarget,
      waveColor: "#a3bffa",
      progressColor: "#667eea",
      cursorColor: "#4c51bf",
      cursorWidth: 2,
      height: 180,
      barWidth: 2,
      barGap: 1,
      barRadius: 2,
      normalize: true,
      plugins: [this.regions]
    })

    this.wavesurfer.on("ready", () => {
      this.updateTotalTime()
      this.saveDuration()
      this.setStatus("Ready — click and drag on the waveform to select a region")
      this.currentBuffer = this.wavesurfer.getDecodedData()
    })

    this.wavesurfer.on("timeupdate", (time) => {
      this.currentTimeTarget.textContent = this.formatTime(time)
    })

    this.wavesurfer.on("loading", (percent) => {
      this.setStatus(`Loading audio... ${percent}%`)
    })

    // When playback finishes, reset play button
    this.wavesurfer.on("finish", () => {
      this.playBtnTarget.textContent = "Play"
    })

    // Click on empty waveform area clears the active region
    this.wavesurfer.on("click", () => {
      if (this.activeRegion) {
        this.activeRegion.remove()
        this.activeRegion = null
      }
    })

    // Enable drag-to-create regions
    this.regionsDragUnsub = this.regions.enableDragSelection({
      color: "rgba(102, 126, 234, 0.25)"
    })

    this.regions.on("region-created", (region) => {
      // Only allow one region at a time
      if (this.activeRegion && this.activeRegion !== region) {
        this.activeRegion.remove()
      }
      this.activeRegion = region
      this.updateRegionInfo(region)
      this.showRegionControls()
    })

    this.regions.on("region-updated", (region) => {
      this.updateRegionInfo(region)
    })

    this.regions.on("region-removed", (region) => {
      if (this.activeRegion === region) {
        this.activeRegion = null
        this.hideRegionControls()
      }
    })

    this.wavesurfer.load(this.audioUrlValue)
  }

  // ── Playback ────────────────────────────────────────────

  playPause() {
    if (this.wavesurfer.isPlaying()) {
      this.wavesurfer.pause()
      this.playBtnTarget.textContent = "Play"
    } else {
      this.wavesurfer.play()
      this.playBtnTarget.textContent = "Pause"
    }
  }

  stop() {
    this.wavesurfer.stop()
    this.playBtnTarget.textContent = "Play"
  }

  skipToStart() {
    this.wavesurfer.setTime(0)
    if (this.wavesurfer.isPlaying()) {
      this.wavesurfer.pause()
      this.playBtnTarget.textContent = "Play"
    }
  }

  playRegion() {
    if (this.activeRegion) {
      this.activeRegion.play()
      this.playBtnTarget.textContent = "Pause"
    }
  }

  // ── Playback speed ─────────────────────────────────────

  toggleSpeed() {
    const speeds = [1.0, 0.75, 0.5]
    const labels = ["1x", "0.75x", "0.5x"]
    const currentIndex = speeds.indexOf(this.playbackRate)
    const nextIndex = (currentIndex + 1) % speeds.length

    this.playbackRate = speeds[nextIndex]
    this.wavesurfer.setPlaybackRate(this.playbackRate)

    if (this.hasSpeedBtnTarget) {
      this.speedBtnTarget.textContent = labels[nextIndex]
    }
  }

  // ── Zoom ────────────────────────────────────────────────

  zoom() {
    const value = this.zoomSliderTarget.value
    this.wavesurfer.zoom(Number(value))
  }

  zoomIn() {
    const slider = this.zoomSliderTarget
    slider.value = Math.min(Number(slider.value) + 20, Number(slider.max))
    this.zoom()
  }

  zoomOut() {
    const slider = this.zoomSliderTarget
    slider.value = Math.max(Number(slider.value) - 20, Number(slider.min))
    this.zoom()
  }

  // ── Editing ─────────────────────────────────────────────

  trimToRegion() {
    if (!this.activeRegion || !this.currentBuffer) return
    this.pushUndo()

    const { start, end } = this.activeRegion
    const buffer = this.currentBuffer
    const sampleRate = buffer.sampleRate
    const startSample = Math.floor(start * sampleRate)
    const endSample = Math.floor(end * sampleRate)
    const length = endSample - startSample

    const newBuffer = new AudioBuffer({
      numberOfChannels: buffer.numberOfChannels,
      length: length,
      sampleRate: sampleRate
    })

    for (let ch = 0; ch < buffer.numberOfChannels; ch++) {
      const oldData = buffer.getChannelData(ch)
      const newData = newBuffer.getChannelData(ch)
      for (let i = 0; i < length; i++) {
        newData[i] = oldData[startSample + i]
      }
    }

    this.loadBuffer(newBuffer)
    this.setStatus(`Trimmed to ${this.formatTime(start)} – ${this.formatTime(end)}`)
  }

  cutRegion() {
    if (!this.activeRegion || !this.currentBuffer) return
    this.pushUndo()

    const { start, end } = this.activeRegion
    const buffer = this.currentBuffer
    const sampleRate = buffer.sampleRate
    const startSample = Math.floor(start * sampleRate)
    const endSample = Math.floor(end * sampleRate)
    const cutLength = endSample - startSample
    const newLength = buffer.length - cutLength

    if (newLength <= 0) {
      this.setStatus("Cannot cut — nothing would remain")
      return
    }

    const newBuffer = new AudioBuffer({
      numberOfChannels: buffer.numberOfChannels,
      length: newLength,
      sampleRate: sampleRate
    })

    for (let ch = 0; ch < buffer.numberOfChannels; ch++) {
      const oldData = buffer.getChannelData(ch)
      const newData = newBuffer.getChannelData(ch)
      // Copy before the cut
      for (let i = 0; i < startSample; i++) {
        newData[i] = oldData[i]
      }
      // Copy after the cut
      for (let i = endSample; i < buffer.length; i++) {
        newData[i - cutLength] = oldData[i]
      }
    }

    this.loadBuffer(newBuffer)
    this.setStatus(`Cut ${this.formatTime(start)} – ${this.formatTime(end)} (${this.formatTime(end - start)} removed)`)
  }

  trimStart() {
    if (!this.currentBuffer) return
    const time = this.wavesurfer.getCurrentTime()
    if (time <= 0) return
    this.pushUndo()

    const buffer = this.currentBuffer
    const sampleRate = buffer.sampleRate
    const startSample = Math.floor(time * sampleRate)
    const newLength = buffer.length - startSample

    const newBuffer = new AudioBuffer({
      numberOfChannels: buffer.numberOfChannels,
      length: newLength,
      sampleRate: sampleRate
    })

    for (let ch = 0; ch < buffer.numberOfChannels; ch++) {
      const oldData = buffer.getChannelData(ch)
      const newData = newBuffer.getChannelData(ch)
      for (let i = 0; i < newLength; i++) {
        newData[i] = oldData[startSample + i]
      }
    }

    this.loadBuffer(newBuffer)
    this.setStatus(`Trimmed start at ${this.formatTime(time)}`)
  }

  trimEnd() {
    if (!this.currentBuffer) return
    const time = this.wavesurfer.getCurrentTime()
    const duration = this.currentBuffer.duration
    if (time >= duration) return
    this.pushUndo()

    const buffer = this.currentBuffer
    const sampleRate = buffer.sampleRate
    const endSample = Math.floor(time * sampleRate)

    const newBuffer = new AudioBuffer({
      numberOfChannels: buffer.numberOfChannels,
      length: endSample,
      sampleRate: sampleRate
    })

    for (let ch = 0; ch < buffer.numberOfChannels; ch++) {
      const oldData = buffer.getChannelData(ch)
      const newData = newBuffer.getChannelData(ch)
      for (let i = 0; i < endSample; i++) {
        newData[i] = oldData[i]
      }
    }

    this.loadBuffer(newBuffer)
    this.setStatus(`Trimmed end at ${this.formatTime(time)}`)
  }

  // ── Undo ────────────────────────────────────────────────

  pushUndo() {
    this.history.push(this.currentBuffer)
    // Keep max 20 undo steps
    if (this.history.length > 20) this.history.shift()
    this.updateUndoBtn()
  }

  undo() {
    if (this.history.length === 0) return
    const previousBuffer = this.history.pop()
    this.loadBuffer(previousBuffer, false)
    this.updateUndoBtn()
    this.setStatus("Last edit undone")
  }

  updateUndoBtn() {
    if (this.hasUndoBtnTarget) {
      this.undoBtnTarget.disabled = this.history.length === 0
    }
  }

  // ── Clear region ────────────────────────────────────────

  clearRegion() {
    if (this.activeRegion) {
      this.activeRegion.remove()
      this.activeRegion = null
    }
  }

  // ── Save ────────────────────────────────────────────────

  async saveEdit() {
    if (!this.currentBuffer || this.isProcessing) return

    this.isProcessing = true
    this.saveBtnTarget.disabled = true
    this.setStatus("Encoding audio...")

    try {
      const wavBlob = this.encodeWAV(this.currentBuffer)
      const formData = new FormData()
      formData.append("audio", wavBlob, "edited_sermon.wav")

      this.setStatus("Uploading...")

      const response = await fetch(this.saveUrlValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": this.csrfTokenValue,
          "Accept": "application/json"
        },
        body: formData
      })

      if (response.ok) {
        const data = await response.json()
        window.location.href = data.redirect_to
      } else {
        this.setStatus("Save failed — please try again")
      }
    } catch (e) {
      this.setStatus(`Error: ${e.message}`)
    } finally {
      this.isProcessing = false
      this.saveBtnTarget.disabled = false
    }
  }

  // ── Restore original ───────────────────────────────────

  async restoreOriginal() {
    if (!confirm("Restore the original unedited audio? This will discard all edits.")) return

    const form = document.createElement("form")
    form.method = "POST"
    form.action = this.restoreUrlValue

    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = "patch"
    form.appendChild(methodInput)

    const tokenInput = document.createElement("input")
    tokenInput.type = "hidden"
    tokenInput.name = "authenticity_token"
    tokenInput.value = this.csrfTokenValue
    form.appendChild(tokenInput)

    document.body.appendChild(form)
    form.submit()
  }

  // ── Internal helpers ────────────────────────────────────

  loadBuffer(buffer, pushToHistory = true) {
    this.currentBuffer = buffer
    if (this.activeRegion) {
      this.activeRegion.remove()
      this.activeRegion = null
    }

    // Render the new buffer as a blob URL
    const wavBlob = this.encodeWAV(buffer)
    const url = URL.createObjectURL(wavBlob)
    this.wavesurfer.load(url)
    this.wavesurfer.once("ready", () => URL.revokeObjectURL(url))

    if (pushToHistory) this.updateUndoBtn()
  }

  encodeWAV(buffer) {
    const numChannels = buffer.numberOfChannels
    const sampleRate = buffer.sampleRate
    const format = 1 // PCM
    const bitsPerSample = 16
    const bytesPerSample = bitsPerSample / 8
    const blockAlign = numChannels * bytesPerSample
    const dataLength = buffer.length * blockAlign
    const headerLength = 44
    const totalLength = headerLength + dataLength

    const arrayBuffer = new ArrayBuffer(totalLength)
    const view = new DataView(arrayBuffer)

    // WAV header
    this.writeString(view, 0, "RIFF")
    view.setUint32(4, totalLength - 8, true)
    this.writeString(view, 8, "WAVE")
    this.writeString(view, 12, "fmt ")
    view.setUint32(16, 16, true) // chunk size
    view.setUint16(20, format, true)
    view.setUint16(22, numChannels, true)
    view.setUint32(24, sampleRate, true)
    view.setUint32(28, sampleRate * blockAlign, true)
    view.setUint16(32, blockAlign, true)
    view.setUint16(34, bitsPerSample, true)
    this.writeString(view, 36, "data")
    view.setUint32(40, dataLength, true)

    // Interleave channel data
    const channels = []
    for (let ch = 0; ch < numChannels; ch++) {
      channels.push(buffer.getChannelData(ch))
    }

    let offset = 44
    for (let i = 0; i < buffer.length; i++) {
      for (let ch = 0; ch < numChannels; ch++) {
        const sample = Math.max(-1, Math.min(1, channels[ch][i]))
        const val = sample < 0 ? sample * 0x8000 : sample * 0x7FFF
        view.setInt16(offset, val, true)
        offset += 2
      }
    }

    return new Blob([arrayBuffer], { type: "audio/wav" })
  }

  writeString(view, offset, string) {
    for (let i = 0; i < string.length; i++) {
      view.setUint8(offset + i, string.charCodeAt(i))
    }
  }

  updateRegionInfo(region) {
    if (this.hasRegionStartTarget) {
      this.regionStartTarget.textContent = this.formatTime(region.start)
    }
    if (this.hasRegionEndTarget) {
      this.regionEndTarget.textContent = this.formatTime(region.end)
    }
    if (this.hasRegionDurationTarget) {
      this.regionDurationTarget.textContent = this.formatTime(region.end - region.start)
    }
  }

  showRegionControls() {
    if (this.hasRegionControlsTarget) {
      this.regionControlsTarget.classList.remove("hidden")
    }
    if (this.hasRegionHintTarget) {
      this.regionHintTarget.classList.add("hidden")
    }
  }

  hideRegionControls() {
    if (this.hasRegionControlsTarget) {
      this.regionControlsTarget.classList.add("hidden")
    }
    if (this.hasRegionHintTarget) {
      this.regionHintTarget.classList.remove("hidden")
    }
  }

  updateTotalTime() {
    const duration = this.wavesurfer.getDuration()
    this.totalTimeTarget.textContent = this.formatTime(duration)
  }

  saveDuration() {
    if (!this.hasDurationUrlValue) return
    const duration = Math.round(this.wavesurfer.getDuration())
    fetch(this.durationUrlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfTokenValue,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ duration_seconds: duration })
    })
  }

  setStatus(msg) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
    }
  }

  formatTime(seconds) {
    if (isNaN(seconds) || seconds < 0) return "0:00"
    const m = Math.floor(seconds / 60)
    const s = Math.floor(seconds % 60)
    const ms = Math.floor((seconds % 1) * 10)
    return `${m}:${s.toString().padStart(2, "0")}.${ms}`
  }
}
