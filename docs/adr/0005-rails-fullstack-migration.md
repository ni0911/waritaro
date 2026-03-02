# ADR 0005: Rails フルスタック移行

- **ステータス**: Accepted
- **作成日**: 2026-03-02
- **決定者**: ni0911
- **Supersedes**: [ADR 0001](0001-repository-pattern.md), [ADR 0002](0002-frontend-tech-stack.md), [ADR 0003](0003-deployment-target.md)

## 背景

React + TypeScript + LocalStorage SPA として開発してきた「ワリタロ会計部」を、
Ruby on Rails フルスタック構成へ全面移行する。

主な動機:

- **Rails スキル習得**: 業務で Rails を使うスキルを身につけることが目的
- **データ永続化**: LocalStorage はデバイスをまたいだ同期ができない。DBベースの永続化が必要
- **Issue #1・#2 の仕様改善**: 負担比率の改善・精算モデルの変更を伴うため、移行タイミングで一括設計する

## 検討した選択肢

### 選択肢 1: React SPA + Rails API（フロント/バックエンド分離）

- メリット: 既存のフロントコードを活かせる。SPA の操作感を維持できる
- デメリット: 2つのデプロイ先の管理が必要。CORS 設定・JWT 認証など追加の複雑さが生まれる。Rails スキル習得よりも React スキルの継続になってしまう

### 選択肢 2: Rails フルスタック + Hotwire（採用）

サーバーサイドレンダリングで HTML を返し、Hotwire（Turbo + Stimulus）で部分更新・インタラクティブ性を付加する構成。

- メリット: 単一の Rails アプリだけ管理すればよい。Hotwire により SPA に近い操作感を実現できる。Rails の MVC フルスタックを学べる。認証（Devise）の追加が容易
- デメリット: Hotwire の学習コストがある。フロントの既存コードは全て作り直しになる

### 選択肢 3: Next.js（SSR）+ Prisma + PostgreSQL

- メリット: TypeScript の知識を活かせる。Next.js の SSR で SEO 対応も容易
- デメリット: Rails スキル習得という目的に合わない。Node.js サーバーのインフラ運用が必要

## 決定

**Rails 8 + Hotwire（Turbo + Stimulus）+ Tailwind CSS を採用する。**

理由:
1. Rails スキル習得という目的に最も合致する
2. フルスタック単一アプリで管理・デプロイがシンプル
3. Hotwire により SPAに近い UX を実現しつつ、複雑な JS を書かずに済む
4. 将来の Devise 認証追加が容易

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

## 結果

### ポジティブな影響

- Rails MVC フルスタックの実装経験を積める
- 単一アプリで DB・認証・ビューをまとめて管理できる
- Hotwire により部分更新・インライン編集が少ない JS で実現できる
- Render.com の無料プランで PostgreSQL 永続化 + Web サービスを一元管理できる

### ネガティブな影響・トレードオフ

- React で実装した全フロントコードが不要になる
- Hotwire（特に Turbo Stream）の学習コストがある
- Render.com 無料プランはインスタンスがスリープするため、初回アクセスが遅い場合がある

### 今後の対応

- 認証追加時は Devise を導入し、`ApplicationController` に `before_action :authenticate_user!` を追加する
- アクセス増加時は有料プランへのアップグレードを検討する
