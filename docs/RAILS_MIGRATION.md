# Rails 移行設計ドキュメント

> **対応 Issue**: #1（負担比率の改善）、#2（払い先の設計見直し）、#3（Rails 全面移行）

## 概要

React + TypeScript + LocalStorage SPA を Ruby on Rails フルスタック構成に全面移行する。
Rails スキル習得を主目的とし、データ永続化と仕様改善を同時に実施する。
その後、認証機能（Rails 8 generate authentication）とマルチテナント対応（グループモデル）を追加した。

## 技術スタック

| 項目 | 採用技術 |
|------|---------|
| フレームワーク | Rails 8 |
| 認証 | Rails 8 標準認証（generate authentication / bcrypt） |
| フロントエンド | Hotwire（Turbo + Stimulus）|
| CSS | Tailwind CSS v4 |
| JS バンドル | Importmap |
| アセットパイプライン | Propshaft |
| DB（開発） | SQLite3 |
| DB（本番） | PostgreSQL |
| デプロイ | Render.com |

## データモデル

### ER 図

```
User ──── Setting（グループ）
          │
          ├── Card  ←── TemplateItem
          ├── Card  ←── SheetItem ──→ Sheet
          └── TemplateItem ←── SheetItem（template_item_id、参照のみ）

Session ──→ User
```

### モデル定義

#### User

```ruby
# email_address:  string  NOT NULL UNIQUE
# password_digest: string  NOT NULL
# setting_id:     integer (nullable, FK → settings)
```

#### Session

```ruby
# user_id:    integer NOT NULL FK → users
# ip_address: string
# user_agent: string
```

#### Setting（グループ）

```ruby
# member_a:    string  NOT NULL default: "たろう"
# member_b:    string  NOT NULL default: "はなこ"
# owner_id:    integer (nullable, FK → users) ... グループ作成者
# invite_code: string  UNIQUE               ... 招待用コード（hex 8バイト）
```

#### Card

```ruby
# name:       string  NOT NULL
# owner:      string  NOT NULL ("A" or "B")
# setting_id: integer NOT NULL FK → settings
```

#### TemplateItem

```ruby
# name:       string  NOT NULL
# amount:     integer NOT NULL default: 0
# burden_a:   integer NOT NULL default: 0
# burden_b:   integer NOT NULL default: 0
# card_id:    integer (nullable, FK → cards)
# sort_order: integer NOT NULL default: 0
# setting_id: integer NOT NULL FK → settings
```

#### Sheet

```ruby
# year_month: string  NOT NULL UNIQUE per setting_id (例: "2026-03")
# setting_id: integer NOT NULL FK → settings
```

#### SheetItem

```ruby
# name:               string  NOT NULL
# amount:             integer NOT NULL default: 0
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
  resource :session
  resources :passwords, param: :token

  # ユーザー登録
  get  "register", to: "registrations#new",    as: :new_registration
  post "register", to: "registrations#create", as: :registrations

  # グループ作成・参加
  resource :setting, only: [:show, :update] do
    get  :new_group,    on: :member
    post :create_group, on: :member
    get  :join,         on: :member
    post :join,         on: :member
  end

  root "sheets#index"

  resources :sheets, param: :year_month, only: [:index, :create, :destroy] do
    member do
      get  :settlement
      post :apply_template
    end
    resources :sheet_items, only: [:create, :destroy, :edit, :update] do
      member do
        get   :cancel
        patch :update_burden
        patch :update_amount
      end
    end
  end

  resources :template_items, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      patch :reorder
    end
  end

  resources :cards, only: [:index, :new, :create, :edit, :update, :destroy]
end
```

## 認証・グループフロー

```
/register     → RegistrationsController#new / create
/session/new  → SessionsController#new（ログイン）
/session      → SessionsController#create / destroy

登録後:
  setting_id: nil → /setting/new_group へリダイレクト
  /setting/new_group  → グループ作成フォーム
  /setting/create_group → setting 作成、user.setting = @setting
  /setting/join       → 招待コード入力
  （POST）            → invite_code で setting 検索、user.setting = @setting
```

ApplicationController の before_action:
1. `require_authentication` — 未ログインは `/session/new` へ
2. `require_group_membership` — グループ未参加は `/setting/new_group` へ
3. `set_setting` — `@setting = current_user.setting`

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
| [0008](adr/0008-remove-payer-burden-only-settlement.md) | 払い手＋負担額精算モデルの削除 | Accepted |
| [0009](adr/0009-mobile-ux-improvements.md) | モバイル UX 改善（iOS Safari 対応） | Accepted |
| [0010](adr/0010-authentication-and-group-model.md) | 認証基盤導入とグループモデル設計 | Accepted |
