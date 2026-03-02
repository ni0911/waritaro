import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "message", "confirmBtn"]

  // data-action="confirm-modal#open" を持つ要素から呼ぶ
  // data-confirm-modal-message-param と data-confirm-modal-form-param を渡す
  open(event) {
    const message = event.params.message || "本当に削除しますか？"
    const formId  = event.params.form

    this.messageTarget.textContent = message
    this._formId = formId
    this.backdropTarget.classList.remove("hidden")
  }

  confirm() {
    if (this._formId) {
      document.getElementById(this._formId)?.requestSubmit()
    }
    this.close()
  }

  cancel() {
    this.close()
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    this._formId = null
  }
}
