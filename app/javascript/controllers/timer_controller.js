import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "display", "phase", "roundInfo", "exerciseInfo", "exerciseName",
    "progress", "startBtn", "pauseBtn", "resetBtn", "completeForm", "exerciseListItem"
  ]
  static values = {
    exercises: { type: Array, default: [] },
    rounds: { type: Number, default: 1 },
    prepSeconds: { type: Number, default: 5 }
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
    this.phase = "ready" // "ready", "prep", "exercise", "rest", "complete"
    this.isRunning = false
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

  get isCompleted() {
    return this.phase === "complete"
  }

  get nextExerciseName() {
    // If not the last exercise, return the next exercise name
    if (this.currentExerciseIndex < this.totalExercises - 1) {
      return this.exercisesValue[this.currentExerciseIndex + 1].name
    }
    // If last exercise but not last round, return the first exercise name
    if (this.currentRound < this.roundsValue) {
      return this.exercisesValue[0].name
    }
    // Last exercise of last round
    return null
  }

  start() {
    if (this.isRunning || this.isCompleted) return
    this.initAudioContext()
    this.requestWakeLock()
    this.isRunning = true

    // Start with preparation phase if not already started
    if (this.phase === "ready") {
      this.phase = "prep"
      this.remainingSeconds = this.prepSecondsValue
      this.updateDisplay()
    }

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
    if (this.phase === "prep") {
      // After preparation, start first exercise
      this.phase = "exercise"
      this.remainingSeconds = this.currentExercise.exerciseSeconds
    } else if (this.phase === "exercise") {
      // Check if this is the last exercise of the last round
      const isLastExercise = this.currentExerciseIndex >= this.totalExercises - 1
      const isLastRound = this.currentRound >= this.roundsValue

      if (isLastExercise && isLastRound) {
        // Skip rest and complete immediately
        this.complete()
        return
      }

      // After exercise, go to rest
      this.phase = "rest"
      this.remainingSeconds = this.currentExercise.restSeconds

      // Speak next exercise name
      this.speak(`次は ${this.nextExerciseName}`)
    } else if (this.phase === "rest") {
      // After rest, go to next exercise or next round
      if (this.currentExerciseIndex < this.totalExercises - 1) {
        // Move to next exercise
        this.currentExerciseIndex++
        this.phase = "exercise"
        this.remainingSeconds = this.currentExercise.exerciseSeconds
      } else {
        // Finished all exercises in this round, start next round
        this.currentRound++
        this.currentExerciseIndex = 0
        this.phase = "exercise"
        this.remainingSeconds = this.currentExercise.exerciseSeconds
      }
    }

    this.updateDisplay()
    this.updateExerciseListHighlight()
  }

  complete() {
    clearInterval(this.timer)
    this.isRunning = false
    this.phase = "complete"
    this.releaseWakeLock()
    this.phaseTarget.textContent = "Complete!"
    const allColors = Object.values(this.phaseConfig).map(c => c.color)
    this.phaseTarget.classList.remove(...allColors)
    this.phaseTarget.classList.add("bg-blue-500")
    this.displayTarget.textContent = "00:00"
    this.playComplete()
    this.speak("お疲れ様でした")
    this.toggleButtons()
  }

  get phaseConfig() {
    return {
      ready: { label: "Ready", color: "bg-blue-500" },
      prep: { label: "Get Ready!", color: "bg-purple-500" },
      exercise: { label: "Exercise", color: "bg-green-500" },
      rest: { label: "Rest", color: "bg-yellow-500" }
    }
  }

  get totalPhaseSeconds() {
    switch (this.phase) {
      case "prep": return this.prepSecondsValue
      case "exercise": return this.currentExercise.exerciseSeconds
      case "rest": return this.currentExercise.restSeconds
      default: return this.currentExercise.exerciseSeconds
    }
  }

  updateDisplay() {
    const mins = Math.floor(this.remainingSeconds / 60)
    const secs = this.remainingSeconds % 60
    this.displayTarget.textContent = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`

    // Update phase label and colors
    const config = this.phaseConfig[this.phase]
    if (config) {
      this.phaseTarget.textContent = config.label
      const allColors = Object.values(this.phaseConfig).map(c => c.color)
      this.phaseTarget.classList.remove(...allColors)
      this.phaseTarget.classList.add(config.color)
    }

    if (this.hasExerciseNameTarget) {
      if (this.phase === "ready" || this.phase === "prep") {
        this.exerciseNameTarget.textContent = `最初: ${this.currentExercise.name}`
      } else if (this.phase === "exercise") {
        this.exerciseNameTarget.textContent = this.currentExercise.name
      } else {
        this.exerciseNameTarget.textContent = `次は ${this.nextExerciseName}`
      }
    }
    if (this.hasRoundInfoTarget) {
      this.roundInfoTarget.textContent = `Round ${this.currentRound} / ${this.roundsValue}`
    }
    if (this.hasExerciseInfoTarget) {
      this.exerciseInfoTarget.textContent = `${this.currentExerciseIndex + 1} / ${this.totalExercises}`
    }

    // Calculate progress
    const progress = ((this.totalPhaseSeconds - this.remainingSeconds) / this.totalPhaseSeconds) * 100
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
    this.resetBtnTarget.classList.toggle("hidden", this.isCompleted)
    this.completeFormTarget.classList.toggle("hidden", !this.isCompleted)
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

  speak(text) {
    try {
      if ('speechSynthesis' in window) {
        const utterance = new SpeechSynthesisUtterance(text)
        utterance.lang = 'ja-JP'
        utterance.rate = 1.0
        speechSynthesis.speak(utterance)
      }
    } catch (e) {
      console.log("Speech synthesis not supported:", e)
    }
  }
}
