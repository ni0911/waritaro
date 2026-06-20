# ワリタロ 設計ドキュメント（図）

Issue #43「汎用立替清算への再構築」(ADR 0013) 後の設計図。
すべて [Mermaid](https://mermaid.js.org/) で記述しており、GitHub・VS Code(拡張)・対応ビューアでそのまま描画される。

| ドキュメント | 内容 |
|------------|------|
| [er.md](er.md) | **ER図** — 論理データモデル（エンティティと関連・カーディナリティ） |
| [usecase.md](usecase.md) | **ユースケース図** — アクターと機能の関係 |
| [sequence.md](sequence.md) | **シーケンス図** — 割り勘追加 / 精算確定 / 招待参加 / 最小送金算出 |
| [physical-schema.md](physical-schema.md) | **物理項目図** — テーブル定義（物理名・型・制約・索引・FK） |

## 用語

| 用語 | 説明 |
|------|------|
| Group | 清算グループ（旅行・飲み会・シェアハウス・カップル月次など）。旧 `Setting` を一般化 |
| Member | グループの参加者。`user_id` 任意（名前だけの同行者も可）。「あなた」= `user_id == current_user.id` |
| Expense | 1件の立替。`payer`（立て替えた人）と `amount`、`expense_date` を持つ |
| ExpenseShare | 各メンバーの負担額。`Σ(shares.amount) == expense.amount` が不変条件 |
| Settlement | 精算スナップショット。確定時に未精算 Expense をひも付け「精算済み」にする |
| net（純収支） | `Σ(payした額) − Σ(負担額)`。+ = 受け取る / − = 支払う。総和は常に 0 |
| 最小送金 | net を最小回数の送金プランに変換（貪欲法 / debt simplification）。`SettlementService` |

> 関連: [ADR 0013](../adr/0013-general-purpose-settlement-rebuild.md)
