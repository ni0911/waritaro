# ADR 0006: 項目別負担額モデル（burden_a / burden_b）の採用

- **ステータス**: Accepted
- **作成日**: 2026-03-02
- **決定者**: ni0911

## 背景

現行設計では `Sheet` に `splitRatio`（例: A:60%, B:40%）を持ち、
全 `SheetItem` に同一の比率を適用していた。

この設計では「家賃は A:80,000円 / B:40,000円 の固定分担」のような
**項目ごとの個別負担額**が設定できない。
また、`isSplit: boolean` によって「割り勘」か「私物」かの2択しか表現できない。

## 検討した選択肢

### 選択肢 1: isSplit + グローバル splitRatio（現行）

- メリット: シンプル。スライダー1つで全体の比率を変更できる
- デメリット: 項目ごとの個別負担額を設定できない。家賃のような固定額分担に対応できない

### 選択肢 2: 項目ごとの比率（customRatio）

各 `SheetItem` に `ratio_a: integer`（0〜100）を持たせる。

- メリット: 比率の概念を維持しつつ個別設定が可能
- デメリット: 比率 → 金額への変換で端数が発生する。「A:80,000円 / B:40,000円」のような固定額指定ができない

### 選択肢 3: 項目ごとの負担額（burden_a / burden_b）（採用）

各 `SheetItem` に `burden_a: integer`、`burden_b: integer` を持たせる。

- 割り勘（50:50）: `burden_a = burden_b = amount / 2`（切り捨て、端数は burden_a に＋1）
- 固定額: `burden_a`・`burden_b` を個別入力
- 私物（精算対象外）: `burden_a = burden_b = 0`

- メリット: 端数計算が明確。固定額・割り勘・私物の3モードを統一した設計で表現できる。`isSplit` フラグが不要になり設計がシンプルになる
- デメリット: 金額変更時に burden も再計算が必要（割り勘モード選択時は自動計算するため UX は問題なし）

## 決定

**`burden_a` / `burden_b` を SheetItem および TemplateItem に追加し、グローバル `splitRatio` を廃止する。**

理由:
- 固定額分担（家賃など）と割り勘の混在という実際のユースケースに対応できる
- `isSplit` フラグを廃止し、`burden_a == 0 && burden_b == 0` で「私物」を表現することで設計が統一される
- 端数が金額レベルで管理されるため、精算額の誤差が生まれない

## データモデル変更

```
SheetItem:
  - 廃止: isSplit:boolean
  - 廃止: Sheet.splitRatio
  - 追加: burden_a:integer (default: 0)
  - 追加: burden_b:integer (default: 0)

TemplateItem:
  - 廃止: isSplit:boolean
  - 追加: burden_a:integer (default: 0)
  - 追加: burden_b:integer (default: 0)
```

## UI 変更

各 SheetItem 行に分担モード選択 UI を追加:
```
[割り勘] [A:____円  B:____円] [私物]
```
- `burden_selector` Stimulus コントローラーが担当

## 結果

### ポジティブな影響

- 固定額分担・割り勘・私物の3パターンを1つの設計で統一表現できる
- グローバル比率スライダーが不要になり、UI がシンプルになる
- 端数が明確に管理され、精算計算の誤差がなくなる

### ネガティブな影響・トレードオフ

- 金額変更時、割り勘モードなら burden を再計算する UX が必要
- 「全項目一括で比率変更」の操作ができなくなる（実用上は問題ないと判断）
