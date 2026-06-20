# ADR 0013: 汎用立替清算への再構築（N人・payer/share モデル）

- **ステータス**: Accepted
- **作成日**: 2026-06-20
- **決定者**: ni0911
- **関連 Issue**: [#43](https://github.com/ni0911/waritaro/issues/43)（エピック）, #12
- **Supersedes**: [ADR 0004](0004-settlement-calculation-logic.md)（2者振替）, [ADR 0006](0006-per-item-burden-model.md)（burden_a/b 2列）, [ADR 0007](0007-shared-account-settlement.md), [ADR 0008](0008-remove-payer-burden-only-settlement.md)（payer 廃止）, [ADR 0010](0010-authentication-and-group-model.md) の一部（User↔Group の単一所属）

## 背景

waritaro は「同棲・固定2人・月次」を強く前提とした設計だった。

- `Setting` = グループ。`member_a` / `member_b` の2人固定
- `User belongs_to :setting`（1ユーザー1グループ）
- `Sheet` = 月次コンテナ（`year_month`）
- `SheetItem` = 各費用。`burden_a` / `burden_b`（各自が共同口座へ入れる負担額）
- `SettlementService` = `deposit_a` / `deposit_b` の2者入金額のみ算出（payer は ADR 0008 で廃止）

この設計は旅行・飲み会・イベント・シェアハウスなど「人数可変・誰が立て替えたか」が本質のユースケースに対応できない。Issue #43 では **あらゆる立替清算に対応する汎用サービスへの再構築** に方向性を合意した。

## 決定

### 1. ドメインモデルを payer / share 方式へ再構築

固定2列の `burden_a/b` を廃止し、**「立て替えた人(payer)」と「負担する人たち(shares)」** を持つ汎用モデルにする。

| モデル | 役割 | 主な属性 |
|--------|------|----------|
| `User` | 認証アカウント（不変） | email, password_digest, name |
| `Group` | 清算グループ（`Setting` を一般化） | name, icon(絵文字), tile(色), kind, invite_code, created_by |
| `Member` | グループの参加者（A/B 固定を撤廃） | group_id, user_id(任意), name, color, sort_order |
| `Expense` | 1件の立替（`Sheet`+`SheetItem` を一般化） | group_id, payer_id(Member), title, amount, expense_date, split_mode, settlement_id(任意) |
| `ExpenseShare` | 各メンバーの負担 | expense_id, member_id, amount |
| `Settlement` | 清算スナップショット | group_id, settled_at |

- **Member は登録ユーザーとは独立**。`user_id` は任意。旅行の同行者を「名前だけ」で追加でき、招待コードで後から `User` に紐付け（claim）できる。
- 「あなた」= `member.user_id == current_user.id`。
- 不変条件: 各 `Expense` で `Σ(expense_shares.amount) == expenses.amount`。これにより全メンバーの純収支の総和は常に 0。

### 2. User ↔ Group を多対多へ（ADR 0010 の単一所属を更新）

旧: `User belongs_to :setting`（1グループ固定）。
新: ユーザーは複数グループに所属できる（沖縄旅行・ルームシェア・飲み会…を同時に）。所属は `Member.user_id` の紐付けで表現する。

```ruby
# ユーザーが参加しているグループ
Group.joins(:members).where(members: { user_id: current_user.id })
```

`current_setting`（単一）→ **グループ選択方式**（URL `/groups/:id` でスコープ）へ移行。ホーム(root)は所属グループ一覧。グループ操作は「current_user に紐づく Member が存在するか」で認可する。

### 3. 清算ロジックを N人最小送金（debt simplification）へ

各メンバーの純収支 `net = Σ(自分が払った Expense.amount) − Σ(自分の ExpenseShare.amount)`（+ = 受け取るべき / − = 支払うべき、総和 0）。
これを **最小回数の送金プラン** に貪欲法で変換する（デザインの `settlePlan` と等価）。

1. nets を creditors(正) と debtors(負) に分割し各々降順ソート
2. 最大の債務者と最大の債権者をマッチングし `min(債務,債権)` を送金。0 になった側を進める
3. `[{from, to, amount}]` を返す

```ruby
SettlementService::Plan     = Data.define(:transfers, :nets)
SettlementService::Transfer = Data.define(:from, :to, :amount) # from/to は Member
```

n 人なら送金回数は高々 n−1 回。2者の場合は旧 `transfer_a + transfer_b = 0` と一致する（後方互換）。

### 4. 「月次シート」前提の撤廃と清算スナップショット

`Sheet`(year_month) を廃止し、清算スコープを **Group 単位の連続台帳** にする。グループは任意のタイミングで「精算する」= `Settlement` を作成し、その時点の未精算 `Expense` 群を確定（`settlement_id` を付与）してリセットできる。

- ライブ残高 = `settlement_id IS NULL` の Expense から算出。
- 「精算済み」グループ = ライブ残高が全員 0。`Settlement` は履歴として残る。
- 旧「月次運用」は「毎月グループで精算する」運用で代替可能（特別なシート概念は不要）。

### 5. 共有・出力の汎用化

`ShareTextService` を N人のグループ精算プラン用テキストに書き換える（`buildGroupSettleText` 相当）。LINE 共有 URL スキーム（`https://line.me/R/share?text=`）を一級市民として維持しつつ、コピー/その他にも対応。

## 後方互換 / データ移行

既存の本番データ（同棲カップル）を新ドメインへ移行する。**本番安全マイグレーションの原則**（モデルクラス不使用・raw SQL）に従う。

| 旧 | 新 | 変換 |
|----|----|------|
| `Setting` | `Group` | name = `"#{member_a}・#{member_b}"`, icon=🏠, invite_code 引継ぎ, created_by=owner |
| `member_a` / `member_b` | `Member` ×2 | A は owner ユーザーに、B は他ユーザーがいれば紐付け |
| （共同口座） | `Member`「共同口座」(user_id=nil) | 旧モデルは「各自が共同口座へ入金」。これを payer=共同口座 として表現 |
| `SheetItem` (burden_a/b) | `Expense` + `ExpenseShare` ×2 | payer=共同口座, amount=burden_a+burden_b, shares={A:burden_a, B:burden_b} |
| `Sheet`(月) | `Settlement` | 各月＝独立した清算スナップショット。最新月のみ未精算で継続可 |
| `Card` / `TemplateItem` | （廃止） | 共同口座運用専用のため新ドメインでは持たない |

**精算結果の不変性（回帰テスト）**: 旧 `SettlementService` の `deposit_a` は「A が共同口座へ入れる額」だった。新モデルでは payer=共同口座 なので、共同口座の net = +Σ(amount)、A の net = −Σ(burden_a)。最小送金プランは「A → 共同口座 ¥Σ(burden_a)」「B → 共同口座 ¥Σ(burden_b)」となり、旧 deposit と一致する。これを回帰スペックで担保する。

## 検討した選択肢

### モデル: 既存テーブルへ payer 列を増分追加（不採用）

`Sheet`/`SheetItem` を維持し payer 列と N メンバーを足す案。変更は小さいが、月次 Sheet 前提と burden 2列の制約が残り、Issue #43 の「再構築」方針に反する。将来の負債になるため不採用。

### 清算スコープ: 旧 Sheet を Group にマッピング（不採用）

各月を独立 Group にすると同一カップルが月ごとに分断され UX が悪い。Group=連続台帳 + Settlement スナップショットの方が汎用ユースケース（旅行＝1回精算、シェアハウス＝定期精算）に自然。

## 結果

### ポジティブ

- 旅行・飲み会・シェアハウス・カップル月次のすべてを単一モデルで表現できる
- N人精算が最小送金で算出される（#12 を内包）
- payer/share により「誰が立て替えたか」を正しく記録（ADR 0008 の制約を解消）
- ユーザーが複数グループを持てる

### ネガティブ・トレードオフ

- スキーマ・コントローラ・UI の広範な書き換えが必要（複数 PR に分割）
- 共同口座運用（Card/TemplateItem）の専用機能は一旦廃止。必要なら将来「定期支出テンプレート」として再導入
- `current_setting` を前提にした全コントローラ・ビューの改修

## 段階実装（子タスク）

1. 新ドメインモデル + マイグレーション（本 ADR）
2. N人最小送金 `SettlementService` 書き換え
3. `ShareTextService`（N人 LINE 共有）
4. 後方互換データ移行 + 回帰テスト
5. コントローラ + ルーティング刷新（N グループ対応認証）
6. 新 UI（ホーム/グループ/追加フロー/共有）— design_handoff_waritaro 準拠
