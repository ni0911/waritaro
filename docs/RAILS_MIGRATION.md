# Rails 移行設計ドキュメント

> **対応 Issue**: #1（負担比率の改善）、#2（払い先の設計見直し）、#3（Rails 全面移行）

## 概要

React + TypeScript + LocalStorage SPA を Ruby on Rails フルスタック構成に全面移行する。
Rails スキル習得を主目的とし、データ永続化と仕様改善を同時に実施する。

## 技術スタック

| 項目 | 採用技術 |
|------|---------|
| フレームワーク | Rails 8 |
| フロントエンド | Hotwire（Turbo + Stimulus）|
| CSS | Tailwind CSS |
| JS バンドル | Importmap |
| アセットパイプライン | Propshaft |
| DB（開発） | SQLite3 |
| DB（本番） | PostgreSQL |
| デプロイ | Render.com（無料プラン）|

## データモデル

### ER 図

```
Setting (1レコード)
Card  ←── TemplateItem
Card  ←── SheetItem ──→ Sheet
TemplateItem ←── SheetItem (template_item_id, 参照のみ)
```

### モデル定義

#### Setting

```ruby
# member_a: string (デフォルト: "たろう")
# member_b: string (デフォルト: "はなこ")
```

#### Card

```ruby
# name:  string  NOT NULL
# owner: string  NOT NULL ("A" or "B")
```

#### TemplateItem

```ruby
# name:       string  NOT NULL
# amount:     integer NOT NULL default: 0
# payer:      string  NOT NULL ("A" or "B")
# burden_a:   integer NOT NULL default: 0
# burden_b:   integer NOT NULL default: 0
# card_id:    integer (nullable, FK → cards)
# sort_order: integer NOT NULL default: 0
```

#### Sheet

```ruby
# year_month: string NOT NULL UNIQUE (例: "2026-03")
```

#### SheetItem

```ruby
# name:               string  NOT NULL
# amount:             integer NOT NULL default: 0
# payer:              string  NOT NULL ("A" or "B")
# burden_a:           integer NOT NULL default: 0
# burden_b:           integer NOT NULL default: 0
# card_id:            integer (nullable, FK → cards)
# is_from_template:   boolean NOT NULL default: false
# template_item_id:   integer (nullable, FK → template_items)
# sheet_id:           integer NOT NULL FK → sheets
```

## 仕様変更サマリ

### Issue #1: 負担比率の改善

**廃止**: `Sheet.split_ratio_a/b`、`SheetItem.is_split`
**追加**: `SheetItem.burden_a`、`SheetItem.burden_b`

分担モード:
- **割り勘**: `burden_a = burden_b = amount ÷ 2`（切り捨て、端数は burden_a に＋1）
- **固定額**: `burden_a` / `burden_b` を個別入力
- **私物**: `burden_a = burden_b = 0`（精算対象外）

詳細: [ADR 0006](adr/0006-per-item-burden-model.md)

### Issue #2: 払い先の設計見直し

**廃止**: `SettlementResult.diff / payer / payee`（A→B 払いモデル）
**採用**: `transfer_a / transfer_b`（各自が共有口座に振り込む金額）

```
transfer_a = sum(burden_a) - sum(amount where payer="A" かつ精算対象)
transfer_b = sum(burden_b) - sum(amount where payer="B" かつ精算対象)
```

詳細: [ADR 0007](adr/0007-shared-account-settlement.md)

## ルーティング

```ruby
Rails.application.routes.draw do
  root "sheets#index"

  resources :sheets, param: :year_month, only: [:index, :create, :destroy] do
    member do
      get  :settlement
      post :apply_template
    end
    resources :sheet_items, only: [:create, :destroy] do
      member do
        patch :update_burden  # burden_a / burden_b の更新
        patch :update_amount  # 金額のインライン編集
      end
    end
  end

  resources :template_items, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      patch :reorder
    end
  end

  resources :cards, only: [:index, :new, :create, :edit, :update, :destroy]
  resource :setting, only: [:show, :update]
end
```

## Stimulus コントローラー

| コントローラー | 用途 |
|--------------|------|
| `confirm_modal` | 削除確認ダイアログ |
| `prompt_modal` | 年月入力ダイアログ |
| `burden_selector` | 分担モード切り替え（割り勘 / 固定 / 私物）|
| `inline_edit` | 金額インライン編集（タップ → input → Enter で送信）|
| `sortable` | テンプレート並び替え（Sortable.js）|
| `copy_text` | LINE共有テキストをクリップボードにコピー |

## Turbo Stream 活用箇所

| アクション | Turbo Stream 操作 |
|-----------|-----------------|
| SheetItem 追加 | `append #sheet_items_list` |
| SheetItem 削除 | `remove #sheet_item_<id>` |
| SheetItem update_burden | `replace #sheet_item_<id>` |
| SheetItem update_amount | `replace #sheet_item_<id>` |
| TemplateItem 削除 | `remove #template_item_<id>` |
| Card 削除 | `remove #card_<id>` |

## デプロイ設定（Render.com）

### `bin/render-build.sh`

```bash
#!/usr/bin/env bash
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
```

### 環境変数

| 変数 | 説明 |
|------|------|
| `RAILS_MASTER_KEY` | `config/master.key` の内容 |
| `DATABASE_URL` | Render PostgreSQL から自動設定 |
| `RAILS_LOG_TO_STDOUT` | `1` |

## 移行元ファイル参照

| 既存ファイル | 参照目的 |
|-----------|---------|
| `src/services/settlementService.ts` | 精算ロジックの移植元 |
| `src/services/shareTextService.ts` | 共有テキスト生成の移植元 |
| `src/pages/SheetScreen.tsx` | カード別グループ化ロジックの参考 |
| `src/types/index.ts` | 全データモデルの定義 |

## ADR 一覧

| ADR | タイトル | ステータス |
|-----|---------|---------|
| [0001](adr/0001-repository-pattern.md) | リポジトリパターン | Superseded by 0005 |
| [0002](adr/0002-frontend-tech-stack.md) | フロントエンド技術スタック | Superseded by 0005 |
| [0003](adr/0003-deployment-target.md) | デプロイ先 | Superseded by 0005 |
| [0004](adr/0004-settlement-calculation-logic.md) | 精算計算ロジック | Superseded by 0007 |
| [0005](adr/0005-rails-fullstack-migration.md) | Rails フルスタック移行 | Accepted |
| [0006](adr/0006-per-item-burden-model.md) | 項目別負担額モデル | Accepted |
| [0007](adr/0007-shared-account-settlement.md) | 共有口座精算モデル | Accepted |
