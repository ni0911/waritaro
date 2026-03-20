import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["splitBtn", "customBtn", "customFields",
                    "burdenA", "burdenB", "hiddenA", "hiddenB"]
  static values  = { amount: Number, mode: String }

  connect() {
    if (this.modeValue === 'custom') {
      this.setCustom()
    } else {
      this.setSplit()
    }
  }

  setSplit() {
    const half = Math.floor(this.amountValue / 2)
    const rem  = this.amountValue - half * 2
    this._setHidden(half + rem, half)
    this._hideCustom()
    this._activateBtn(this.splitBtnTarget)
    this._deactivateBtn(this.customBtnTarget)
  }

  setCustom() {
    this._showCustom()
    this._setHidden(0, 0)
    this._activateBtn(this.customBtnTarget)
    this._deactivateBtn(this.splitBtnTarget)
  }

  updateAmount(event) {
    this.amountValue = parseInt(event.target.value) || 0
  }

  amountValueChanged(value) {
    if (!this.customBtnTarget.classList.contains("wt-mode-btn--active")) {
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
    btn.classList.add("wt-mode-btn--active")
  }

  _deactivateBtn(btn) {
    btn.classList.remove("wt-mode-btn--active")
  }
}
