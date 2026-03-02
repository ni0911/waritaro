import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "feedback"]

  async copy() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value)
      this.feedbackTarget.classList.remove("hidden")
      setTimeout(() => this.feedbackTarget.classList.add("hidden"), 2000)
    } catch {
      // fallback
      this.sourceTarget.classList.remove("hidden")
      this.sourceTarget.select()
      document.execCommand("copy")
      this.sourceTarget.classList.add("hidden")
    }
  }
}
