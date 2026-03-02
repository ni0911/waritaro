import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["splitBtn", "customBtn", "privateBtn", "customFields",
                    "burdenA", "burdenB", "hiddenA", "hiddenB"]
  static values  = { amount: Number }

  connect() {
    this.setSplit()
  }

  setSplit() {
    const half = Math.floor(this.amountValue / 2)
    const rem  = this.amountValue - half * 2
    this._setHidden(half + rem, half)
    this._hideCustom()
    this._activateBtn(this.splitBtnTarget)
    this._deactivateBtn(this.customBtnTarget)
    this._deactivateBtn(this.privateBtnTarget)
  }

  setCustom() {
    this._showCustom()
    this._setHidden(0, 0)
    this._activateBtn(this.customBtnTarget)
    this._deactivateBtn(this.splitBtnTarget)
    this._deactivateBtn(this.privateBtnTarget)
  }

  setPrivate() {
    this._setHidden(0, 0)
    this._hideCustom()
    this._activateBtn(this.privateBtnTarget)
    this._deactivateBtn(this.splitBtnTarget)
    this._deactivateBtn(this.customBtnTarget)
  }

  amountValueChanged(value) {
    if (!this.customBtnTarget.classList.contains("border-blue-500")) {
      this.setSplit()
    }
  }

  _setHidden(a, b) {
    this.hiddenATarget.value = a
    this.hiddenBTarget.value = b
  }

  _showCustom() {
    this.customFieldsTarget.classList.remove("hidden")
    this.customFieldsTarget.classList.add("flex")
    this.hiddenATarget.disabled = true
    this.hiddenBTarget.disabled = true
  }

  _hideCustom() {
    this.customFieldsTarget.classList.add("hidden")
    this.customFieldsTarget.classList.remove("flex")
    this.hiddenATarget.disabled = false
    this.hiddenBTarget.disabled = false
  }

  _activateBtn(btn) {
    btn.classList.add("border-blue-500", "bg-blue-50", "text-blue-700")
    btn.classList.remove("border-gray-300", "text-gray-600")
  }

  _deactivateBtn(btn) {
    btn.classList.remove("border-blue-500", "bg-blue-50", "text-blue-700")
    btn.classList.add("border-gray-300", "text-gray-600")
  }
}
