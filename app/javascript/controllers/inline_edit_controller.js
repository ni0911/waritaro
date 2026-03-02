import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values  = { url: String, field: String }

  startEdit() {
    this.displayTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  async submit(event) {
    if (event.type === "keydown" && event.key !== "Enter") return
    const value = this.inputTarget.value
    const body  = new URLSearchParams({
      [this.fieldValue]: value,
      _method: "patch"
    })
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const response  = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body
    })
    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }

  cancel() {
    this.inputTarget.classList.add("hidden")
    this.displayTarget.classList.remove("hidden")
  }
}
