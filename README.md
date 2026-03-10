# ワリタロ会計部

同棲・カップル・ルームメイトなど2人ペアで使える、毎月の支払い管理 Web アプリ。
アカウント登録 → グループ作成 → 招待コードでパートナーを招待し、グループ単位でデータを管理する。

## 機能

- **認証・グループ管理** — メール＋パスワードで登録。グループを作成し招待コードでパートナーを招待
- **月次シート** — 月ごとに費用を記録。テンプレートからワンタップで固定費を一括コピー
- **項目別負担額** — 費用ごとに「割り勘 / 固定額 / 私物（精算対象外）」を設定
- **精算計算（共有口座モデル）** — 各自が共有口座に振り込む金額を自動計算
- **金額インライン編集** — リスト上でタップ → 数値入力 → Enter で即時更新
- **LINE 共有テキスト** — 精算結果をクリップボードにコピーして LINE で共有
- **固定費テンプレート** — 毎月繰り返す費用をテンプレート登録・並び替え
- **カード管理** — クレカを登録し費用に紐付け。カード別の引き落とし額を確認
- **メンバー名設定** — 2人の名前を設定すると全画面・共有テキストに反映

## 技術スタック

| 項目 | 技術 |
|------|------|
| フレームワーク | Ruby on Rails 8.0.2 |
| 認証 | Rails 8 標準認証（`generate authentication` / bcrypt） |
| フロントエンド | Hotwire（Turbo + Stimulus） |
| スタイル | Tailwind CSS v4 |
| アセット | Propshaft + Importmap |
| DB（開発） | SQLite3 |
| DB（本番） | PostgreSQL |
| テスト | RSpec + FactoryBot + shoulda-matchers |
| デプロイ | Render.com（Web Service） |

## ローカル起動

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/dev
```

`bin/dev` は Rails サーバーと Tailwind CSS の watch を同時起動します。
ブラウザで http://localhost:3000 にアクセスしてください。

初回アクセス時はログインページにリダイレクトされます。「新規登録」からアカウントを作成し、グループを設定してください。

## テスト

```bash
bundle exec rspec
```

## デプロイ（Render.com）

### 初回セットアップ

1. https://render.com にサインアップ（GitHub アカウントで可）
2. **New > Web Service** → GitHub リポジトリを連携
3. 以下を設定：

| 項目 | 値 |
|------|------|
| Runtime | Ruby |
| Build Command | `./bin/render-build.sh` |
| Start Command | `bundle exec puma -C config/puma.rb` |

4. **Environment Variables** に以下を追加：

| キー | 値 |
|------|------|
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | `config/master.key` の内容 |
| `DATABASE_URL` | Render PostgreSQL（または外部 DB）の接続文字列 |

5. **Create Web Service** でデプロイ開始

ビルド時に `bin/render-build.sh` が自動実行され、`bundle install` → アセットビルド → DB マイグレーションまで完了します。

### 以降のデプロイ

`main` ブランチに `git push` すると自動で再デプロイされます。

## ドキュメント

設計の詳細は [`docs/adr/`](docs/adr/) の ADR（アーキテクチャ決定記録）を参照してください。

| ADR | タイトル |
|-----|---------|
| [0005](docs/adr/0005-rails-fullstack-migration.md) | Rails フルスタック移行 |
| [0006](docs/adr/0006-per-item-burden-model.md) | 項目別負担額モデル |
| [0007](docs/adr/0007-shared-account-settlement.md) | 共有口座精算モデル |
| [0008](docs/adr/0008-remove-payer-burden-only-settlement.md) | 払い手＋負担額精算モデルの削除 |
| [0009](docs/adr/0009-mobile-ux-improvements.md) | モバイル UX 改善（iOS Safari 対応） |
| [0010](docs/adr/0010-authentication-and-group-model.md) | 認証基盤導入とグループモデル設計 |
