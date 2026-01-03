import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "phase", "setInfo", "progress", "startBtn", "pauseBtn", "resetBtn"]
  static values = {
    exerciseSeconds: { type: Number, default: 30 },
    restSeconds: { type: Number, default: 15 },
    totalSets: { type: Number, default: 5 }
  }

  connect() {
    this.reset()
  }

  reset() {
    this.currentSet = 1
    this.isExercise = true
    this.remainingSeconds = this.exerciseSecondsValue
    this.isRunning = false
    this.isPaused = false
    clearInterval(this.timer)
    this.updateDisplay()
    this.toggleButtons()
  }

  start() {
    if (this.isRunning) return
    this.isRunning = true
    this.isPaused = false
    this.toggleButtons()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  pause() {
    if (!this.isRunning) return
    this.isRunning = false
    this.isPaused = true
    clearInterval(this.timer)
    this.toggleButtons()
  }

  tick() {
    this.remainingSeconds--
    this.updateDisplay()

    if (this.remainingSeconds <= 0) {
      this.playBeep()
      this.nextPhase()
    } else if (this.remainingSeconds <= 3) {
      this.playTick()
    }
  }

  nextPhase() {
    if (this.isExercise) {
      this.isExercise = false
      this.remainingSeconds = this.restSecondsValue
    } else {
      if (this.currentSet >= this.totalSetsValue) {
        this.complete()
        return
      }
      this.currentSet++
      this.isExercise = true
      this.remainingSeconds = this.exerciseSecondsValue
    }
    this.updateDisplay()
  }

  complete() {
    clearInterval(this.timer)
    this.isRunning = false
    this.phaseTarget.textContent = "Complete!"
    this.phaseTarget.classList.remove("bg-green-500", "bg-yellow-500")
    this.phaseTarget.classList.add("bg-blue-500")
    this.displayTarget.textContent = "00:00"
    this.playComplete()
    this.toggleButtons()
  }

  updateDisplay() {
    const mins = Math.floor(this.remainingSeconds / 60)
    const secs = this.remainingSeconds % 60
    this.displayTarget.textContent = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`

    this.phaseTarget.textContent = this.isExercise ? "Exercise" : "Rest"
    this.phaseTarget.classList.toggle("bg-green-500", this.isExercise)
    this.phaseTarget.classList.toggle("bg-yellow-500", !this.isExercise)

    this.setInfoTarget.textContent = `Set ${this.currentSet} / ${this.totalSetsValue}`

    const totalPhaseSeconds = this.isExercise ? this.exerciseSecondsValue : this.restSecondsValue
    const progress = ((totalPhaseSeconds - this.remainingSeconds) / totalPhaseSeconds) * 100
    this.progressTarget.style.width = `${progress}%`
  }

  toggleButtons() {
    this.startBtnTarget.classList.toggle("hidden", this.isRunning)
    this.pauseBtnTarget.classList.toggle("hidden", !this.isRunning)
  }

  playBeep() {
    this.playTone(880, 0.3)
  }

  playTick() {
    this.playTone(440, 0.1)
  }

  playComplete() {
    this.playTone(523.25, 0.2)
    setTimeout(() => this.playTone(659.25, 0.2), 200)
    setTimeout(() => this.playTone(783.99, 0.4), 400)
  }

  playTone(frequency, duration) {
    try {
      const audioContext = new (window.AudioContext || window.webkitAudioContext)()
      const oscillator = audioContext.createOscillator()
      const gainNode = audioContext.createGain()

      oscillator.connect(gainNode)
      gainNode.connect(audioContext.destination)

      oscillator.frequency.value = frequency
      oscillator.type = "sine"

      gainNode.gain.setValueAtTime(0.3, audioContext.currentTime)
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration)

      oscillator.start(audioContext.currentTime)
      oscillator.stop(audioContext.currentTime + duration)
    } catch (e) {
      console.log("Audio not supported")
    }
  }

  updateExercise(event) {
    this.exerciseSecondsValue = parseInt(event.target.value)
    if (!this.isRunning && this.isExercise) {
      this.remainingSeconds = this.exerciseSecondsValue
      this.updateDisplay()
    }
  }

  updateRest(event) {
    this.restSecondsValue = parseInt(event.target.value)
    if (!this.isRunning && !this.isExercise) {
      this.remainingSeconds = this.restSecondsValue
      this.updateDisplay()
    }
  }

  updateSets(event) {
    this.totalSetsValue = parseInt(event.target.value)
    this.updateDisplay()
  }
}
