import { Controller } from "@hotwired/stimulus"

// 負担額の自動計算コントローラー
// amount と burden_a を入力すると burden_b を自動補完（逆も同様）
export default class extends Controller {
  static targets = ["amount", "burdenA", "burdenB"]

  // amount または burden_a が変わったとき → burden_b を自動計算
  calcBurdenB() {
    const amount = parseInt(this.amountTarget.value) || 0
    const burdenA = parseInt(this.burdenATarget.value) || 0
    this.burdenBTarget.value = Math.max(0, amount - burdenA)
  }

  // burden_b が変わったとき → burden_a を自動計算
  calcBurdenA() {
    const amount = parseInt(this.amountTarget.value) || 0
    const burdenB = parseInt(this.burdenBTarget.value) || 0
    this.burdenATarget.value = Math.max(0, amount - burdenB)
  }
}
