# ADR 0011: Rails 8.1 移行に伴う Ruby 3.3.10 への引き上げ

- **ステータス**: Accepted
- **作成日**: 2026-05-31
- **決定者**: ni0911

---

## 背景

Dependabot が Rails を 8.0.4 → 8.1.3 に上げる PR（#18）を作成した。
ローカル検証すると、Ruby 3.3.0 環境で以下の `SyntaxError` が発生し、アプリ・テストともに起動不能になった。

```
actionview-8.1.3/.../capture_helper.rb:50:
anonymous rest parameter is also used within block (SyntaxError)
```

これは Rails 8.1 の actionview が使う匿名引数（`*`）のブロック内利用が、
**Ruby 3.3.0 ピンポイントのパーサーバグ**で構文エラー扱いになるもの。Ruby 3.3.1 以降で修正済み。

つまり Rails 8.1 を採用するには、Ruby ランタイムを 3.3.1 以降へ引き上げる必要があった。

---

## 検討した選択肢

### 選択肢 1: Rails 8.1 を見送り 8.0 系に留まる

- メリット: Ruby を触らずに済む
- デメリット: 今後の Rails セキュリティ更新・依存更新の足かせになる。Dependabot PR が滞留し続ける

### 選択肢 2: Ruby を最新の 3.3.x（3.3.10）に上げる（採用）

- メリット: パッチ更新なので言語仕様の変更がなく影響が最小。3.3.10 はローカルに rbenv で導入済みだった
- デメリット: `.ruby-version` / `Dockerfile`（本番）を更新する必要がある。ネイティブ拡張の再コンパイルが必要

### 選択肢 3: Ruby を 3.4.x に上げる

- メリット: 最新のランタイム機能・性能改善が得られる
- デメリット: マイナー更新のため言語仕様・gem 互換の検証コストが大きい。今回の目的（Rails 8.1 を通す）には過剰

---

## 決定

**Ruby を 3.3.0 → 3.3.10、Rails を 8.0.4 → 8.1.3 に更新する。**

最小の変更で Rails 8.1 を通すため、Ruby は同一マイナー系列の最新パッチ 3.3.10 を採用した。

### 変更ファイル

| ファイル | 変更内容 |
|---------|---------|
| `.ruby-version` | `3.3.0` → `3.3.10`（ローカル + CI が参照） |
| `Dockerfile` | `ARG RUBY_VERSION=3.3.0` → `3.3.10`（Render 本番は `env: docker` のためここが本番 Ruby になる） |
| `Gemfile` | `gem "rails", "~> 8.1.3"`（Dependabot が変更） |
| `Gemfile.lock` | Rails 8.1.3 系へ再生成 |

---

## 理由

- **3.3.x 最新パッチを選択**: Rails 8.1 は Ruby 3.2+ をサポートするが、3.4 へのマイナー更新は検証範囲が広がる。Rails 8.1 を通すだけなら 3.3.0 のパーサーバグを回避できる 3.3.10 で十分
- **CI / 本番の Ruby 追従**: CI（`.github/workflows/ci.yml`）は `ruby-version: .ruby-version` を参照、本番（Render）は Dockerfile の `ARG RUBY_VERSION` を参照しているため、この 2 ファイルの更新でローカル・CI・本番の Ruby が揃う

---

## 影響・注意事項

- **ネイティブ拡張の再コンパイルが必須**: `vendor/bundle` 配下の C 拡張（`.bundle`）は Ruby 3.3.0 でビルドされており、3.3.10 では `LoadError: linked to incompatible ... libruby.3.3.dylib` になる。Ruby のパッチ更新時は `rm -rf vendor/bundle && bundle install` で再コンパイルすること
- **Bundler**: `Gemfile.lock` の `BUNDLED WITH` は 4.0.3（main に元から存在）。Ruby 3.3.10 同梱は 2.5.22 のため、`gem install bundler -v 4.0.3` で明示的に導入してから `bundle install` する
- **テスト件数**: 更新後 101 examples, 0 failures を確認。rubocop もグリーン
- **マージ方式**: Rails 更新（Dependabot）と Ruby 更新（手動コミット）を 1 つの論理変更として squash merge した（PR #18）

---

## 今後の対応

- 次回 Rails メジャー/マイナー更新時も、まず Ruby 要件と既知のパーサー非互換を確認する
- Ruby 3.4 系への更新は、別途まとまった検証時間を取って独立タスクとして実施する
