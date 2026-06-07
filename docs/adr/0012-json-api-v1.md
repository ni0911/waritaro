# ADR 0012: `/api/v1` JSON API の新設

- **ステータス**: Accepted
- **作成日**: 2026-06-06
- **決定者**: ni0911

---

## 背景

waritaro は現状 HTML（Turbo Stream）専用で、`SheetItemsController` などは
`render turbo_stream:` でブラウザの DOM 書き換え指示を返している。これはブラウザ専用の
インターフェースであり、プログラムから利用できる API ではない。

本業の学習目標（① API 設計・実装 → ② OAuth2.0 移行 → ③ Rate Limit）を waritaro を
練習台に積み上げるロードマップのフェーズ1として、`/api/v1` に JSON API を新設する。
API（窓口）が無ければ認証対象もレート制限対象も存在しないため、ここが起点になる。

学習ロードマップの詳細は dev-journal `topics/api-oauth-ratelimit-roadmap` を参照。

---

## 検討した選択肢

### バージョニング方式

| 方式 | 内容 | 判断 |
|------|------|------|
| URL パス（`/api/v1/...`） | 名前空間でバージョンを切る | **採用**。明示的で学習・運用ともに分かりやすい |
| ヘッダ（`Accept: application/vnd.app.v1+json`） | メディアタイプでバージョン指定 | 見送り。ルーティングが不透明になり学習段階では過剰 |
| クエリ（`?version=1`） | パラメータで指定 | 見送り。キャッシュ・ルーティングと相性が悪い |

### ベースコントローラの基底クラス

| 方式 | 内容 | 判断 |
|------|------|------|
| `ActionController::API` | API 用の軽量基底。ビュー/CSRF/Cookie を含まない | **採用**。HTML 用 `ApplicationController` と関心を分離。Cookie 認証流用のため `ActionController::Cookies` を明示的に include |
| `ApplicationController` 継承 | 既存基底を流用 | 見送り。`allow_browser :modern`（User-Agent 必須）が API クライアントを弾く、CSRF・HTML 向けリダイレクトが混入する |

### シリアライズ方式

| 方式 | 判断 |
|------|------|
| **alba** | **採用**。軽量シリアライザ gem。クラスで `attributes` 宣言。本格的なシリアライズ層を体験でき、view 非依存で request spec とも相性が良い |
| jbuilder | 見送り。view 層に寄るため API ロジックが分散する |
| `as_json` 手書き | 見送り。エンドポイントが増えると整形ロジックが重複する |

### 認証

| 方式 | 判断 |
|------|------|
| **既存 Cookie 認証を流用** | **採用（フェーズ1）**。`Authentication` concern の `resume_session`（`cookies.signed[:session_id]`）をそのまま使い、`current_setting` スコープでテナント分離を維持する |
| トークン認証（`Authorization: Bearer`） | フェーズ2（ADR 別途）で導入。ステートレス認証・OAuth2.0 はそこで扱う |

---

## 決定

**`/api/v1` 名前空間に JSON API を新設する。** 主要な方針は以下。

1. **バージョニング**: URL パス方式（`namespace :api { namespace :v1 }`）
2. **基底クラス**: `Api::V1::BaseController < ActionController::API`
   - `include ActionController::Cookies` で Cookie 認証を可能にする
   - `include Authentication` で既存 `resume_session` を流用
   - 認証失敗（`request_authentication`）は **HTML リダイレクトではなく 401 JSON** を返すよう override
   - グループ未所属は **403 JSON** を返す（HTML 版の `new_group` リダイレクトは使わない）
3. **シリアライズ**: alba（`app/serializers/api/v1/`）
4. **認証/テナント分離**: 既存 Cookie 認証を流用し、全エンドポイントを `current_setting` スコープで引く
5. **エラー JSON 形式**: `{ "error": { "code": "...", "message": "..." } }` に統一（フェーズ1-5 で例外ハンドリングを集約）

### ディレクトリ／ファイル構成

```
app/
├── controllers/api/v1/
│   ├── base_controller.rb     # 名前空間・共通処理（認証・テナント・エラー）
│   └── sheets_controller.rb   # GET /api/v1/sheets ほか
└── serializers/api/v1/
    └── sheet_serializer.rb     # alba シリアライザ
config/routes.rb                # namespace :api { namespace :v1 { ... } }
```

### 段階的な実装（フェーズ1のスコープ）

- 1-1 `Api::V1::BaseController`（名前空間・共通処理）★本 ADR の対象
- 1-2 `GET /api/v1/sheets`（一覧 JSON）★本 ADR の対象
- 1-3 `GET /api/v1/sheets/:year_month/settlement`（既存 SettlementService 再利用）
- 1-4 `POST /api/v1/sheets/:ym/sheet_items`（201/422）
- 1-5 エラー JSON 形式統一（例外ハンドリング集約）
- 1-6 ページネーション（`?page=&per_page=`）
- 1-7 request spec で全エンドポイント TDD
- 1-8（余裕あれば）OpenAPI/Swagger でドキュメント化

---

## 理由

- **関心の分離**: HTML（`ApplicationController` = `ActionController::Base`）と API（`ActionController::API`）を
  別系統にすることで、片方の変更が他方に波及しにくい。`allow_browser :modern` や CSRF など
  ブラウザ前提の挙動を API に持ち込まずに済む
- **既存認証の流用**: フェーズ1ではトークン認証を導入せず、確立済みの Cookie セッションを
  そのまま使うことで、API 設計（URL・シリアライズ・ステータスコード）の学習に集中できる。
  ステートレス認証は依存関係的にフェーズ2で扱うのが自然
- **テナント分離の継続**: `current_setting.sheets` のようにグループスコープで引く既存ルールを
  API でも厳守し、マルチテナントの分離（ADR 0010）を崩さない

---

## 影響・注意事項

- **依存追加**: `alba` gem を追加（全環境）
- **CSRF**: `ActionController::API` は CSRF 保護を含まない。フェーズ1は Cookie 認証だが
  GET 中心かつ学習用途のため許容。状態変更系（1-4 の POST 以降）を本格運用する場合は
  フェーズ2のトークン認証移行とあわせて CSRF/CORS 方針を再検討する
- **同一オリジン前提**: フェーズ1の Cookie 認証は同一オリジンからの利用を前提とする。
  別オリジンのクライアントはフェーズ2のトークン認証で対応する

---

## 今後の対応

- フェーズ2でトークン認証（`Authorization: Bearer`）→ OAuth2.0 リソース/認可サーバー化を行う際、
  本 ADR の「Cookie 認証流用」を見直す ADR を別途起票する
- エラー JSON 形式・ページネーション仕様は 1-5 / 1-6 着手時に必要なら追補する
