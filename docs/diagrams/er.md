# ER図（論理データモデル）

ADR 0013 後のドメインモデル。`User` は認証アカウント、`Group` が清算スコープ、
`Expense`＋`ExpenseShare` が payer/share 方式の費用、`Settlement` が精算スナップショット。

```mermaid
erDiagram
    USER ||--o{ SESSION         : "has"
    USER ||--o{ MEMBER          : "linked as (任意)"
    USER ||--o{ GROUP           : "owns (owner_id)"

    GROUP ||--o{ MEMBER         : "has"
    GROUP ||--o{ EXPENSE        : "has"
    GROUP ||--o{ SETTLEMENT     : "has"

    MEMBER ||--o{ EXPENSE       : "pays (payer)"
    MEMBER ||--o{ EXPENSE_SHARE : "owes"

    EXPENSE ||--|{ EXPENSE_SHARE : "split into"
    SETTLEMENT |o--o{ EXPENSE    : "snapshots (任意)"

    USER {
        bigint  id PK
        string  email_address UK "正規化(下げ/trim)"
        string  password_digest "has_secure_password"
        string  name "表示名(任意)"
    }

    SESSION {
        bigint  id PK
        bigint  user_id FK
        string  ip_address
        string  user_agent
    }

    GROUP {
        bigint  id PK
        string  name "グループ名"
        string  icon "絵文字"
        string  tile "タイル色(hex)"
        string  kind "general/couple"
        string  invite_code UK "招待コード(自動採番)"
        bigint  owner_id FK "作成者(任意)"
    }

    MEMBER {
        bigint  id PK
        bigint  group_id FK
        bigint  user_id FK "任意(未登録の同行者はnull)"
        string  name "メンバー名"
        string  color "アバター色(hex)"
        integer sort_order "表示順"
    }

    EXPENSE {
        bigint  id PK
        bigint  group_id FK
        bigint  payer_id FK "立て替えた人(Member)"
        bigint  settlement_id FK "精算済みならスナップショット(任意)"
        string  title "費目"
        integer amount "金額(整数円, >0)"
        date    expense_date "発生日"
        string  split_mode "equal/itemized/ratio"
    }

    EXPENSE_SHARE {
        bigint  id PK
        bigint  expense_id FK
        bigint  member_id FK
        integer amount "負担額(>=0)"
    }

    SETTLEMENT {
        bigint  id PK
        bigint  group_id FK
        datetime settled_at "精算日時"
        string  note "メモ(移行時は年月)"
    }
```

## カーディナリティと不変条件

| 関連 | カーディナリティ | 備考 |
|------|-----------------|------|
| User – Session | 1 : 0..N | ログインセッション |
| User – Member | 1 : 0..N | `members.user_id`。1ユーザーは1グループ内に最大1メンバー（部分一意索引） |
| User – Group(owner) | 1 : 0..N | 作成者。参加関係は Member 経由（多対多） |
| Group – Member | 1 : 1..N | グループには最低1人 |
| Group – Expense | 1 : 0..N | |
| Group – Settlement | 1 : 0..N | 精算のたびに1件 |
| Member – Expense(payer) | 1 : 0..N | 立て替えた人 |
| Member – ExpenseShare | 1 : 0..N | 各人の負担 |
| Expense – ExpenseShare | 1 : 1..N | **`Σ(shares.amount) == expense.amount`** |
| Settlement – Expense | 0..1 : 0..N | `settlement_id IS NULL` = 未精算（ライブ台帳） |

> 各メンバーの純収支 `net = Σ(payした Expense.amount) − Σ(自分の ExpenseShare.amount)` の
> グループ内総和は、上記不変条件により**常に 0**になる。
