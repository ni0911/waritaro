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
| DB（本番） | PostgreSQL（Render.com） |
| テスト | RSpec + FactoryBot + shoulda-matchers |
| デプロイ | Render.com |

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

## デプロイ（Render.com）

1. GitHub にプッシュ
2. Render ダッシュボード → **New > Blueprint Instance** → リポジトリを選択
3. `RAILS_MASTER_KEY` を `config/master.key` の内容で手動設定
4. デプロイ実行

`render.yaml` に Web サービスと PostgreSQL の構成が定義されています。
ビルド時に `bin/render-build.sh` が自動実行され、マイグレーションまで完了します。

## ドキュメント

設計の詳細は [`docs/adr/`](docs/adr/) の ADR（アーキテクチャ決定記録）を参照してください。
