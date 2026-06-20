# ユースケース図

アクターと機能の関係。Mermaid にユースケース図の専用記法はないため、
flowchart でアクター（円）とユースケース（角丸）を表現する。

```mermaid
flowchart LR
    %% アクター
    user(("👤 ユーザー<br/>(立替者/参加者)"))
    invitee(("👥 招待される人"))

    subgraph WARITARO["ワリタロ（システム）"]
        direction TB
        uc_reg(["アカウント登録 / ログイン"])
        uc_group(["グループを作成する"])
        uc_join(["招待コードで参加する"])
        uc_invite(["メンバーを招待する"])
        uc_add(["割り勘を追加する<br/>(均等 / 金額指定)"])
        uc_view(["精算プランを見る<br/>(最小送金)"])
        uc_cal(["カレンダーで記録を見る"])
        uc_share(["LINEで精算を共有する"])
        uc_settle(["精算を確定する<br/>(スナップショット化)"])
        uc_del(["記録を削除する"])
    end

    user --- uc_reg
    user --- uc_group
    user --- uc_join
    user --- uc_invite
    user --- uc_add
    user --- uc_view
    user --- uc_cal
    user --- uc_share
    user --- uc_settle
    user --- uc_del

    invitee --- uc_reg
    invitee --- uc_join

    %% 関連（include/extend 相当）
    uc_add -.->|"自動算出"| uc_view
    uc_view -.->|extend| uc_share
    uc_settle -.->|include| uc_view
    uc_invite -.->|発行| uc_join

    classDef uc fill:#FBF6EE,stroke:#C8704F,color:#3A332A;
    classDef sys fill:#F4EDE2,stroke:#E4D9C9,color:#6E6457;
    class uc_reg,uc_group,uc_join,uc_invite,uc_add,uc_view,uc_cal,uc_share,uc_settle,uc_del uc;
    class WARITARO sys;
```

## ユースケース一覧

| ユースケース | アクター | 主な事前条件 | エンドポイント |
|------------|---------|------------|---------------|
| アカウント登録 / ログイン | ユーザー / 招待される人 | — | `registrations#create` / `sessions#create` |
| グループを作成する | ユーザー | ログイン済み | `groups#create` |
| 招待コードで参加する | ユーザー / 招待される人 | ログイン済み・有効なコード | `memberships#create` |
| メンバーを招待する | ユーザー | グループ所属 | `groups#invite` |
| 割り勘を追加する | ユーザー | グループ所属 | `groups/expenses#create` |
| 精算プランを見る | ユーザー | グループ所属 | `groups#show`（`SettlementService`）|
| カレンダーで記録を見る | ユーザー | ログイン済み | `home#index` |
| LINEで精算を共有する | ユーザー | 未精算あり | `groups#share`（`ShareTextService`）|
| 精算を確定する | ユーザー | 未精算あり | `groups/settlements#create` |
| 記録を削除する | ユーザー | グループ所属 | `groups/expenses#destroy` |

> 認可: `require_authentication`（ログイン必須）→ `require_membership`（未所属はグループ作成へ誘導）
> → グループ操作は `set_member_group`（current_user が Member として参加しているグループのみ）。
