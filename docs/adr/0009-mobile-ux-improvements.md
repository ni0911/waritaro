# ADR 0009: モバイル UX 改善（iOS Safari 対応）

## ステータス

採用済み（2026-03-06）

## 背景

iPhone Safari（特に iPhone SE / 375px 幅）で以下の問題が確認された。

- SheetItem・TemplateItem の分担表示が1行に詰め込まれ、狭い画面でオーバーフローする
- `collection_select` に `text-sm`（14px）が当たっており、iOS Safari のオートズームが発生する可能性がある（iOS Safari は 16px 未満の input/select でズームする）
- 編集(✎)・削除(×)ボタンが `w-6 h-6`（24px）で、iOS 推奨タッチターゲット（44px）を下回る
- 精算結果の「→ 共有口座 に ¥XXX」テキストが長く、折り返しなしで見切れる場合がある

## 決定

### 分担表示の縦並び化

`_sheet_item.html.erb` と `_template_item.html.erb` で、メンバーごとの負担額を `<span class="block">` で縦2行に分離する。

### iOS ズーム防止

`_form.html.erb` / `_edit_form.html.erb` の `collection_select` から `text-sm` を削除し、グローバル CSS の `font-size: 1rem`（16px）が正しく効くようにする。あわせて `py-1.5` → `py-2.5` でタップ領域を拡大。

`inline_edit` の input に重複していた `text-sm text-base` から `text-sm` を削除。

### タッチターゲット拡大

SheetItem の編集・削除ボタンを `w-6 h-6`（24px）→ `w-10 h-10`（40px）に拡大。
TemplateItem の「編集」「削除」リンク・ボタンに `py-2 px-1` を追加してタップ領域を広げる。

### 精算結果の折り返し

`settlement.html.erb` の精算結果コンテナに `flex-wrap gap-1` を追加して、長い精算テキストが折り返せるようにする。

## 理由

- iOS Safari の 16px ズームルールはブラウザ仕様であり、グローバル CSS で `font-size: 1rem` を指定しても個別クラスで上書きされると無効になる
- iOS HIG では最小タッチターゲットを 44×44pt と定義している。24px は明らかに小さく、誤タップが起きやすい
- アプリは `max-w-md` のモバイル専用設計のため、レスポンシブ対応（sm:/md:）は不要

## 影響

- 変更はビュー層のみ（CSS クラスの調整）
- モデル・サービス・ルーティングへの変更なし
- 既存テスト 81 examples すべてグリーンを確認済み
