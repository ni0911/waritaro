import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "input"]

  open(event) {
    const defaultValue = event.params.default || ""
    this._actionUrl  = event.params.url
    this._csrfToken  = document.querySelector('meta[name="csrf-token"]')?.content

    this.inputTarget.value = defaultValue
    this.backdropTarget.classList.remove("hidden")
    setTimeout(() => this.inputTarget.focus(), 50)
  }

  confirm() {
    const value = this.inputTarget.value.trim()
    if (!value) return

    const form = document.createElement("form")
    form.method = "post"
    form.action = this._actionUrl

    const methodInput = document.createElement("input")
    methodInput.type  = "hidden"
    methodInput.name  = "_method"
    methodInput.value = "post"
    form.appendChild(methodInput)

    const csrfInput = document.createElement("input")
    csrfInput.type  = "hidden"
    csrfInput.name  = "authenticity_token"
    csrfInput.value = this._csrfToken
    form.appendChild(csrfInput)

    const ymInput = document.createElement("input")
    ymInput.type  = "hidden"
    ymInput.name  = "sheet[year_month]"
    ymInput.value = value
    form.appendChild(ymInput)

    document.body.appendChild(form)
    form.submit()
  }

  cancel() {
    this.backdropTarget.classList.add("hidden")
  }
}
