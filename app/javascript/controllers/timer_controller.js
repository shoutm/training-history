import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "display", "phase", "roundInfo", "exerciseInfo", "exerciseName",
    "progress", "startBtn", "pauseBtn", "resetBtn", "exerciseListItem"
  ]
  static values = {
    exercises: { type: Array, default: [] },
    rounds: { type: Number, default: 1 }
  }

  connect() {
    this.audioContext = null
    this.wakeLock = null
    this.reset()

    // Re-acquire wake lock when page becomes visible again
    document.addEventListener("visibilitychange", () => {
      if (document.visibilityState === "visible" && this.isRunning) {
        this.requestWakeLock()
      }
    })
  }

  async requestWakeLock() {
    try {
      if ("wakeLock" in navigator) {
        this.wakeLock = await navigator.wakeLock.request("screen")
      }
    } catch (e) {
      console.log("Wake Lock not supported:", e)
    }
  }

  async releaseWakeLock() {
    if (this.wakeLock) {
      await this.wakeLock.release()
      this.wakeLock = null
    }
  }

  initAudioContext() {
    if (!this.audioContext) {
      this.audioContext = new (window.AudioContext || window.webkitAudioContext)()
    }
    // Safari requires resume after user interaction
    if (this.audioContext.state === "suspended") {
      this.audioContext.resume()
    }
  }

  reset() {
    this.currentRound = 1
    this.currentExerciseIndex = 0
    this.isExercise = true
    this.isRunning = false
    this.isCompleted = false
    clearInterval(this.timer)
    this.releaseWakeLock()

    this.remainingSeconds = this.currentExercise.exerciseSeconds

    this.updateDisplay()
    this.toggleButtons()
    this.updateExerciseListHighlight()
  }

  get currentExercise() {
    return this.exercisesValue[this.currentExerciseIndex]
  }

  get totalExercises() {
    return this.exercisesValue.length
  }

  start() {
    if (this.isRunning || this.isCompleted) return
    this.initAudioContext()
    this.requestWakeLock()
    this.isRunning = true
    this.toggleButtons()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  pause() {
    if (!this.isRunning) return
    this.isRunning = false
    clearInterval(this.timer)
    this.releaseWakeLock()
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
      // After exercise, go to rest
      this.isExercise = false
      this.remainingSeconds = this.currentExercise.restSeconds
    } else {
      // After rest, go to next exercise or next round
      if (this.currentExerciseIndex < this.totalExercises - 1) {
        // Move to next exercise
        this.currentExerciseIndex++
        this.isExercise = true
        this.remainingSeconds = this.currentExercise.exerciseSeconds
      } else {
        // Finished all exercises in this round
        if (this.currentRound >= this.roundsValue) {
          this.complete()
          return
        }
        // Start next round
        this.currentRound++
        this.currentExerciseIndex = 0
        this.isExercise = true
        this.remainingSeconds = this.currentExercise.exerciseSeconds
      }
    }

    this.updateDisplay()
    this.updateExerciseListHighlight()
  }

  complete() {
    clearInterval(this.timer)
    this.isRunning = false
    this.isCompleted = true
    this.releaseWakeLock()
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

    if (this.hasExerciseNameTarget) {
      this.exerciseNameTarget.textContent = this.currentExercise.name
    }
    if (this.hasRoundInfoTarget) {
      this.roundInfoTarget.textContent = `Round ${this.currentRound} / ${this.roundsValue}`
    }
    if (this.hasExerciseInfoTarget) {
      this.exerciseInfoTarget.textContent = `${this.currentExerciseIndex + 1} / ${this.totalExercises}`
    }

    const totalPhaseSeconds = this.isExercise ? this.currentExercise.exerciseSeconds : this.currentExercise.restSeconds
    const progress = ((totalPhaseSeconds - this.remainingSeconds) / totalPhaseSeconds) * 100
    this.progressTarget.style.width = `${progress}%`
  }

  updateExerciseListHighlight() {
    if (!this.hasExerciseListItemTarget) return

    this.exerciseListItemTargets.forEach((item, index) => {
      if (index === this.currentExerciseIndex) {
        item.classList.remove("bg-white")
        item.classList.add("bg-blue-100")
      } else {
        item.classList.remove("bg-blue-100")
        item.classList.add("bg-white")
      }
    })
  }

  toggleButtons() {
    this.startBtnTarget.classList.toggle("hidden", this.isRunning || this.isCompleted)
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
      if (!this.audioContext) return

      const oscillator = this.audioContext.createOscillator()
      const gainNode = this.audioContext.createGain()

      oscillator.connect(gainNode)
      gainNode.connect(this.audioContext.destination)

      oscillator.frequency.value = frequency
      oscillator.type = "sine"

      gainNode.gain.setValueAtTime(0.3, this.audioContext.currentTime)
      gainNode.gain.exponentialRampToValueAtTime(0.01, this.audioContext.currentTime + duration)

      oscillator.start(this.audioContext.currentTime)
      oscillator.stop(this.audioContext.currentTime + duration)
    } catch (e) {
      console.log("Audio not supported:", e)
    }
  }
}
