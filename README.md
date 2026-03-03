# ワリタロ会計部

同棲2人の毎月の支払いを管理する Web アプリ。

## 機能

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
| フロントエンド | Hotwire（Turbo + Stimulus） |
| スタイル | Tailwind CSS v4 |
| アセット | Propshaft + Importmap |
| DB（開発） | SQLite3 |
| DB（本番） | PostgreSQL（Neon） |
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

## テスト

```bash
bundle exec rspec
```

## デプロイ（Render.com + Neon）

### 初回セットアップ

**1. Neon で PostgreSQL を作成**

1. https://neon.tech にアクセスしてサインアップ（GitHub アカウントで可）
2. New Project を作成
3. Connection Details から `DATABASE_URL`（`postgresql://...` 形式）をコピー

**2. Render.com で Web Service を作成**

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
| `DATABASE_URL` | Neon からコピーした接続文字列 |

5. **Create Web Service** でデプロイ開始

ビルド時に `bin/render-build.sh` が自動実行され、`bundle install` → アセットビルド → DB マイグレーションまで完了します。

### 以降のデプロイ

`main` ブランチに `git push` すると自動で再デプロイされます。

## ドキュメント

設計の詳細は [`docs/adr/`](docs/adr/) の ADR（アーキテクチャ決定記録）を参照してください。
