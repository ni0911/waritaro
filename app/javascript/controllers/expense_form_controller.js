import { Controller } from "@hotwired/stimulus"

// 割り勘追加フォーム: 金額・参加者・割り方(均等/金額指定)に応じて
// 各人の負担額をライブ計算する。サーバー側でも build_shares で再計算するため、
// ここはあくまで入力支援 + プレビュー。
export default class extends Controller {
  static targets = ["amount", "title", "perEach", "row", "share", "check", "mode", "chip", "modeBtn"]

  connect() { this.recalc() }

  setTitle(event) {
    this.titleTarget.value = event.params.title
    this.chipTargets.forEach((c) => c.classList.toggle("wt-chip-active", c === event.currentTarget))
  }

  toggleMode(event) {
    this.modeTarget.value = event.params.mode
    this.modeBtnTargets.forEach((b) => b.classList.toggle("wt-pill-active", b === event.currentTarget))
    this.recalc()
  }

  recalc() {
    const amount = parseInt(this.amountTarget.value || "0", 10) || 0
    const equal = this.modeTarget.value !== "custom"
    const n = this.checkTargets.filter((c) => c.checked).length

    if (equal) {
      const base = n ? Math.floor(amount / n) : 0
      let rem = n ? amount % n : 0
      this.checkTargets.forEach((c) => {
        const row = c.closest("[data-expense-form-target='row']")
        const share = row.querySelector("[data-expense-form-target='share']")
        if (c.checked) {
          const v = base + (rem > 0 ? 1 : 0)
          if (rem > 0) rem--
          share.value = v
          row.style.opacity = 1
        } else {
          share.value = 0
          row.style.opacity = 0.5
        }
        share.readOnly = true
      })
      this.perEachTarget.textContent = n ? "1人あたり ¥" + base.toLocaleString("ja-JP") : "参加者を選んでね"
    } else {
      this.checkTargets.forEach((c) => {
        const row = c.closest("[data-expense-form-target='row']")
        const share = row.querySelector("[data-expense-form-target='share']")
        share.readOnly = !c.checked
        row.style.opacity = c.checked ? 1 : 0.5
        if (!c.checked) share.value = 0
      })
      const sum = this.shareTargets.reduce((a, s) => a + (parseInt(s.value || "0", 10) || 0), 0)
      const diff = amount - sum
      this.perEachTarget.textContent = diff === 0 ? "ぴったり ✓" : "残り ¥" + diff.toLocaleString("ja-JP")
    }
  }
}
