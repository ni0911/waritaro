# Claude Code 設定

## スタック

- **フレームワーク**: Rails 8.0 + Hotwire（Turbo + Stimulus）
- **CSS**: Tailwind CSS
- **DB（開発）**: SQLite3 / **DB（本番）**: PostgreSQL
- **テスト**: RSpec + FactoryBot + shoulda-matchers

## ディレクトリ構成

```
app/
├── controllers/    # コントローラー
├── models/         # ActiveRecord モデル（バリデーション・アソシエーション）
├── services/       # SettlementService / ShareTextService
├── views/          # ERB テンプレート
└── javascript/
    └── controllers/  # Stimulus コントローラー
spec/
├── models/         # モデルスペック
├── services/       # サービススペック
├── requests/       # リクエストスペック（コントローラー統合テスト）
└── factories/      # FactoryBot ファクトリ
db/
├── migrate/        # マイグレーションファイル
└── seeds.rb        # サンプルデータ
```

## コーディング規約

- **フォーム input**: `text-base`（16px）必須 — iOS Safari のズーム防止
- **削除確認**: `confirm_modal` Stimulus コントローラーを使う（`window.confirm` 禁止）
- **年月入力**: `prompt_modal` Stimulus コントローラーを使う（`window.prompt` 禁止）
- **分担モード切替**: `burden_selector` Stimulus コントローラーを使う
- **金額インライン編集**: `inline_edit` Stimulus コントローラーを使う
- **部分更新**: SheetItem の追加・削除・更新は Turbo Stream で行う

## ドキュメント

- `docs/adr/` — アーキテクチャ決定記録（ADR 0001〜0007）
- `docs/RAILS_MIGRATION.md` — Rails 移行設計ドキュメント（現行）

## ADR の記録

以下に該当する決定をした場合は、作業完了後に「ADR に残しますか？」と必ず確認すること。

- ライブラリ・フレームワークの採用・変更・削除
- データ構造・データモデルの設計変更
- リポジトリ実装の切り替え（例: Supabase 移行）
- ルーティング・認証・状態管理の方式変更
- デプロイ先・CI/CD 構成の変更
- 要件・仕様の大きな変更（機能追加・削除・計算ロジックの変更など）
- 既存の設計を覆す実装方針の変更

## TDD（テスト駆動開発）

**すべての実装は TDD で進めること。**

### 手順

1. **Red**: 失敗するテストを先に書く
2. **Green**: テストが通る最小限の実装を書く
3. **Refactor**: テストを通したまま、コードをきれいにする

### Rails アプリでのテスト構成

- テストフレームワーク: **RSpec**（`rails new -T` で minitest を除外済み）
- モデルスペック: `spec/models/` — バリデーション・アソシエーション・計算ロジック
- サービススペック: `spec/services/` — SettlementService など
- リクエストスペック: `spec/requests/` — コントローラーの統合テスト
- システムスペック: `spec/system/` — E2E（必要に応じて）

### 実装の進め方

- コントローラー実装前に、期待する HTTP レスポンスのリクエストスペックを書く
- モデル実装前に、バリデーション・計算ロジックのモデルスペックを書く
- サービスクラス実装前に、入出力を検証するサービススペックを書く
- `rspec` でグリーンになってから次のステップに進む

## Git 運用

- `git commit` / `git push` はユーザーが明示的に指示するまで実行しない
- コミットメッセージ: `prefix: 日本語メッセージ`（feat / fix / docs / chore / ci など）
- コミットできる粒度になったらコミットすること。ただし**テストが失敗している状態ではコミット禁止**
- コミット時は `/smart-commit` スキルを使うこと

### ブランチ戦略（worktree 優先）

- **新しい作業は git worktree を切って進めることを優先する**（並行開発が基本のため）。`bin/new-worktree <branch-name>` で一発セットアップ。
- **例外:** すでに対象ブランチで作業が始まっている場合は、そのまま継続してよい（途中で worktree に移し替えない）。
- ポート競合はメインと同時起動時に `-p 3001` 等でずらす。

## 開発ワークフロー（要件 → 設計 → 実装 → テスト → 検証 → レビュー → issue）

各フェーズで「いま対応すべきこと」と「次スプリントに持ち越すこと」を切り分け、対象スキルを**自発的に呼ぶ**こと。

### フェーズと、発覚したレビュー指摘の扱い

1. **要件** — ユーザーストーリー・受け入れ条件を確定する
2. **設計** — データモデル・方式を決める。設計を覆す判断・データ構造変更・ライブラリ採用は **ADR に残す**（「ADR の記録」参照）
3. **実装** — TDD（Red → Green → Refactor）で進める
4. **テスト** — model / service / request、必要に応じて system スペック
5. **検証** — ローカル動作確認・空DBからのマイグレーション通し等

上記のどのフェーズでも、レビューや作業中に**対応が必要な指摘**が出たら、次のいずれかに必ず行き先を決める:

- **このPR/ブランチで対応する** → TDD で直し、テストが緑になってからコミット
- **次スプリントに持ち越す** → **`scoped-issue` スキルを自発的に呼んで** 要件化された issue に切る（1 issue = 1 要件、背景・やりたいこと・受け入れ条件・検討事項・参考を構造化）
- **運用で担保する** → render.yaml 等に反映し、PR にその旨を残す

### コードレビュー

- レビューを行うときは **`pr-review-3roles` スキルを自発的に呼ぶ**。
- 必ず **プロダクトオーナー / リードエンジニア / セキュリティエンジニア** の3視点を含める。
- レビュー結果は **必ず PR のコメントとして残す**（チャットだけで終わらせない）。
- 各指摘は重大度（🔴本PRで修正 / 🟡フォローアップ / ⚠️要意思確認）と行き先（本PR / issue番号 / 運用）まで決めて完了とする。

### 関連スキル

- `pr-review-3roles` — 3視点レビュー＋PRコメント投稿（`.claude/skills/`）
- `scoped-issue` — 次スプリント持ち越しタスクの要件化 issue 起票（`.claude/skills/`）
- `smart-commit` — コミット作成

## 本番安全マイグレーションの原則

### 原則 1: マイグレーション内でモデルクラスを使わない

**禁止:** `Setting.first`, `User.create!` など ActiveRecord クラスメソッド
**理由:** スキーマ変更中のモデルキャッシュが不安定になる。`before_create` などコールバックの副作用も起きる。
**代替:** `execute("SELECT id FROM settings ORDER BY id LIMIT 1")` など raw SQL のみ使う

### 原則 2: NOT NULL 追加は「追加 → UPDATE → 検証 → NOT NULL」の4ステップ

```
add_reference ..., null: true   # 1. nullable で追加
execute("UPDATE ...")           # 2. 全行の NULL を埋める
（COUNT で NULL 残存を検証）     # 3. 明示的に検証して raise
change_column_null ..., false   # 4. NOT NULL 制約
```

NULL が残った状態で `change_column_null` を呼ぶと PostgreSQL がエラーを返し、
トランザクションが中断状態になり、以降の全 SQL が `PG::InFailedSqlTransaction` で失敗する。

### 原則 3: preDeployCommand でマイグレーション失敗時のダウンタイムを防ぐ

`render.yaml` に `preDeployCommand: bundle exec rails db:migrate` を設定すること。
entrypoint で `db:migrate` を実行する構成では、マイグレーション失敗 = 新コンテナ起動失敗 = ダウンタイム発生になる。
preDeployCommand ならマイグレーション失敗時にデプロイが中断され、旧コンテナが継続稼働する。
