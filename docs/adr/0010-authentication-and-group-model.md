# ADR 0010: 認証基盤導入とグループモデル設計

- **ステータス**: Accepted
- **作成日**: 2026-03-10
- **決定者**: ni0911
- **Amends**: [ADR 0005](0005-rails-fullstack-migration.md)（「将来 Devise を導入する」方針を変更）

---

## 背景

これまで「ワリタロ会計部」は認証なし・シングルテナント設計だった（`Setting.instance` がグローバルシングルトン）。
不特定多数のカップル・同棲・ルームメイトが独立したデータで利用できるよう、マルチテナント対応が必要になった。

---

## 検討した選択肢

### 選択肢 1: Devise を使う

- メリット: メール確認・パスワードリセット・Remember me など豊富な機能がすぐ使える
- デメリット: Rails 8 の generate authentication と並立させると設定が複雑になる。Devise はジェネレータのカスタマイズ自由度が低く、Rails 標準の流儀とのギャップがある

### 選択肢 2: Rails 8 標準の `rails generate authentication`（採用）

Rails 8.0 に標準搭載された認証ジェネレータ。`User` / `Session` モデルと `Authentication` concern を生成する。

- メリット: gem 追加なし。生成されたコードは全てプロジェクト内に入るため読みやすく修正可能。`has_secure_password` と `bcrypt` だけで完結。Rails の標準思想に沿っている
- デメリット: メール確認・パスワードリセットの UI は自前で実装する必要がある（ジェネレータはメーラーのみ生成）

### 選択肢 3: 外部認証（Auth0 / Supabase Auth など）

- メリット: ソーシャルログイン・MFA が容易
- デメリット: インフラ未経験のため外部サービス依存のリスクを下げたい。コスト・設定コストが大きい

---

## 決定

### 認証方式

**Rails 8 標準の `rails generate authentication` を採用する（Devise 不使用）。**

- `User` モデル（`email_address`, `password_digest`）
- `Session` モデル（`user_id`, `ip_address`, `user_agent`）
- `Authentication` concern（`require_authentication`, `start_new_session_for`, `terminate_session`）

### グループ（マルチテナント）モデル

**`Setting` テーブルをグループエンティティに昇格させる（テーブル名・モデル名は `Setting` のままリネームしない）。**

リネームは工数が大きくリスクがあるため、既存の `Setting` テーブルに `owner_id` / `invite_code` を追加してグループの概念を持たせる。

```
Setting
  ├── member_a / member_b  ... 既存カラム
  ├── owner_id FK → users  ... グループ作成者
  └── invite_code (unique) ... 招待用ランダムコード（hex 8バイト）

User
  └── setting_id FK → settings ... 参加グループ（optional: true）
```

- オーナー（グループ作成者）が `invite_code` を発行し、パートナーに共有
- パートナーが招待コードを入力してグループに参加（`user.setting = setting`）
- 各ユーザーは最大1グループに属する（`optional: true` で未参加を許容）

### データスコープ

`cards` / `sheets` / `template_items` に `setting_id` FK を追加し、グループ単位でデータを分離。`ApplicationController` に `current_setting` ヘルパーを置き、全コントローラーで `current_setting.sheets` のように使う。

`sheet_items` は `sheet → setting` のネストで効くため FK 不要。

### Sheet の uniqueness 制約

`year_month` の uniqueness を `scope: :setting_id` に変更。これにより複数グループが同月のシートを並立して持てる。

---

## 実装詳細

### 主要ファイルの変更

| ファイル | 変更内容 |
|---------|---------|
| `app/controllers/concerns/authentication.rb` | generate authentication が生成（手を加えていない） |
| `app/controllers/application_controller.rb` | `require_authentication`, `require_group_membership`, `current_setting` を追加。`Setting.instance` 廃止 |
| `app/controllers/registrations_controller.rb` | 新規作成。`/register` でユーザー登録 |
| `app/controllers/settings_controller.rb` | `new_group`, `create_group`, `join` アクションを追加 |
| `app/models/setting.rb` | `belongs_to :owner`, `before_create :generate_invite_code` を追加 |
| `app/models/user.rb` | `belongs_to :setting, optional: true`, `validates :email_address` を追加 |
| `app/models/sheet.rb` | `uniqueness: { scope: :setting_id }` に変更 |
| `app/models/card.rb` / `template_item.rb` | `belongs_to :setting` を追加 |
| `config/routes.rb` | `/register`, `/setting/new_group`, `/setting/create_group`, `/setting/join` を追加 |

### グループ参加フロー

```
登録 (/register)
  → グループ設定ページ (/setting/new_group or /setting/join)
      ├── グループ作成 (/setting/create_group)
      │     → setting 作成（invite_code 自動生成）
      │     → user.setting = @setting
      │     → /setting にリダイレクト（招待コード表示）
      └── 招待コードで参加 (/setting/join)
            → invite_code で setting を検索
            → user.setting = @setting
            → / にリダイレクト
```

グループ未参加ユーザーは `/setting/new_group` と `/setting/join` 以外にアクセスできない（`require_group_membership` before_action）。

---

## 理由

- **Setting リネームなし**: テーブル名変更は既存マイグレーション・外部キー・テスト・ビューに広範な影響が出る。機能的に問題なければリネームは「完璧主義」の工数投資。`Setting` という名称で「グループ設定」のセマンティクスは十分伝わる
- **invite_code 方式**: メールベースの招待はメール配信サーバーの設定が必要。コードをコピペして LINE で送る方式の方がユースケース（カップル間のやりとり）に自然にフィット
- **中間テーブルなし**: 1ユーザー1グループという制約を `user.setting_id` の FK で表現。柔軟性は下がるが、シンプルさを優先（グループ移籍・複数グループは現時点で不要）

---

## 影響・注意事項

- **`Setting.instance` 完全廃止**: 全コントローラー・スペックから除去し `current_setting` に統一
- **TemplateItem.all の apply_template**: `current_setting.template_items` にしないと他グループのテンプレートが適用されるバグになる（実装済み）
- **テスト**: 全リクエストスペックに `sign_in(user)` と `let(:setting)` を追加。`spec/support/authentication_helpers.rb` に `sign_in` ヘルパーを追加
- **テスト件数**: 実装後 93 examples, 0 failures を確認

### マイグレーション設計（`add_setting_id_to_app_tables`）

`setting_id` 追加は `change` ではなく `up/down` で段階的に実施:

1. `null: true, foreign_key: false` で追加（既存行を壊さない）
2. 既存行を `Setting.first.id` に一括 UPDATE（データ移行）
3. `change_column_null false` で NOT NULL を強制
4. `add_foreign_key` で FK 制約を追加

`default: 0` を使う方式は `settings.id=0` が存在しないため FK 違反になる。採用しない。

### グループ参加制限

`join` アクションに以下の 2 つのガード処理を追加:

1. **既所属チェック**: `current_user.setting.present?` の場合は `/setting` にリダイレクト
2. **人数上限チェック**: `setting.users.count >= 2` の場合は 422（2人以上の参加を禁止）

---

## 今後の対応

- パスワードリセット UI（`PasswordsController` のビュー整備）
- グループ解散・メンバー変更フロー（現状は招待コード再利用で実質可能）
- アカウント削除機能
