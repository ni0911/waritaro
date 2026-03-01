# Claude Code 設定

## ディレクトリ構成

```
src/
├── types/          # データモデル型定義（編集の起点）
├── repository/
│   ├── interfaces/ # IXxxRepository インターフェース
│   ├── localStorage/ # LocalStorage 実装
│   └── index.ts    # DI エントリーポイント ← Supabase 移行時はここだけ変更
├── services/       # settlementService / shareTextService
├── hooks/          # useCards / useTemplates / useSheets / useSettings
├── pages/          # 画面単位コンポーネント
├── components/     # BottomNav / Header / Layout / Modal
└── utils/          # dateUtils（generateId / nowISO / formatYearMonth）
```

## コーディング規約

- **型インポート**: `import type { Foo } from "..."` を必ず使う（verbatimModuleSyntax）
- **ID 生成**: `generateId()`（= `crypto.randomUUID()`）
- **日時**: `nowISO()`（= ISO8601）
- **非同期**: 全リポジトリメソッドは `async/await` で統一
- **フォーム input**: `text-base`（16px）必須 — iOS Safari のズーム防止
- **window.prompt / confirm 禁止**: `ConfirmModal` / `PromptModal` を使う

## ドキュメント

- `docs/adr/` — アーキテクチャ決定記録（ADR 0001〜0004）
- `docs/PLAN.md` — 設計ドキュメント

## ADR の記録

以下に該当する決定をした場合は、作業完了後に「ADR に残しますか？」と必ず確認すること。

- ライブラリ・フレームワークの採用・変更・削除
- データ構造・データモデルの設計変更
- リポジトリ実装の切り替え（例: Supabase 移行）
- ルーティング・認証・状態管理の方式変更
- デプロイ先・CI/CD 構成の変更
- 要件・仕様の大きな変更（機能追加・削除・計算ロジックの変更など）
- 既存の設計を覆す実装方針の変更

## Git 運用

- `git commit` / `git push` はユーザーが明示的に指示するまで実行しない
- コミットメッセージ: `prefix: 日本語メッセージ`（feat / fix / docs / chore / ci など）
