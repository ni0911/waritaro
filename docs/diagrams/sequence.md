# シーケンス図

主要フローのシーケンス。実装（`app/controllers`・`app/services`・`app/models`）に対応。

## 1. 割り勘を追加する（均等 / 金額指定）

```mermaid
sequenceDiagram
    actor U as ユーザー
    participant V as ブラウザ<br/>(expense_form Stimulus)
    participant C as Groups::ExpensesController
    participant E as Expense / ExpenseShare
    participant DB as DB

    U->>V: 金額・タイトル・立替者・参加者を入力
    Note over V: recalc() で 1人あたり/残りをライブ計算<br/>(均等: 端数は先頭から +1)
    U->>V: 「この内容で記録する」
    V->>C: POST /groups/:id/expenses<br/>amount, title, payer_id, participant_ids[], split_mode, shares{}

    C->>C: build_shares(amount, participants, mode, custom)
    alt split_mode = equal
        C->>C: equal_split → base = amount/n, 端数 amount%n を先頭へ
    else split_mode = custom
        C->>C: shares[member_id] をそのまま採用
    end

    C->>E: group.expenses.new(payer, amount, …) + shares.build
    E->>E: validate（amount>0 / payer同一group / Σshares==amount）
    alt 妥当
        E->>DB: INSERT expenses, expense_shares (1 tx)
        C->>DB: group.touch（更新日時）
        C-->>V: 302 redirect → groups#show
        V-->>U: グループ詳細（更新後の精算プラン）
    else 不正（例: 金額0）
        C-->>V: 422 + フォーム再表示（エラー）
    end
```

## 2. 精算プランの表示と LINE 共有

```mermaid
sequenceDiagram
    actor U as ユーザー
    participant GC as GroupsController
    participant SS as SettlementService
    participant DB as DB
    participant SH as ShareTextService
    participant LINE as LINE 共有URL

    U->>GC: GET /groups/:id
    GC->>SS: new(group).plan
    SS->>DB: open_expenses（settlement_id IS NULL）+ shares 取得
    SS->>SS: compute_nets → { member => net }
    SS->>SS: minimize_transfers(nets)（貪欲法）
    SS-->>GC: Plan(transfers, nets)
    GC-->>U: 「あなたの残高」＋「最少N回の送金」

    U->>GC: GET /groups/:id/share
    GC->>SH: new(group).group_settlement
    SH->>SS: plan.transfers
    SH-->>GC: LINE貼り付け用テキスト
    GC-->>U: メッセージプレビュー
    U->>LINE: 「LINEで送る」(line.me/R/share?text=...)
```

## 3. 精算を確定する（スナップショット化）

```mermaid
sequenceDiagram
    actor U as ユーザー
    participant V as ブラウザ<br/>(confirm_modal)
    participant SC as Groups::SettlementsController
    participant DB as DB

    U->>V: 「精算する」
    V->>U: 確認モーダル表示
    U->>V: OK
    V->>SC: POST /groups/:id/settlement
    alt 未精算あり
        SC->>DB: settlements.create!(settled_at: now) [1 tx]
        SC->>DB: open_expenses.update_all(settlement_id)
        Note over DB: 以後 open_expenses から除外 → 残高 0「精算済み」
        SC-->>U: 302 → groups#show（🎉）
    else 記録なし
        SC-->>U: 302 → groups#show（alert）
    end
```

## 4. 招待コードで参加する（メンバー claim）

```mermaid
sequenceDiagram
    actor U as 参加者
    participant MC as MembershipsController
    participant G as Group / Member
    participant DB as DB

    U->>MC: POST /membership { invite_code }
    MC->>DB: Group.find_by(invite_code)
    alt コード無効
        MC-->>U: 422（招待コードが見つかりません）
    else 既に参加済み
        MC-->>U: 302 → groups#show
    else 参加
        alt 空きメンバー（user_id=nil, 「共同口座」除く）あり
            MC->>G: member.update!(user: current_user) [claim]
        else 空きなし
            MC->>G: members.create!(user, name=display_name, color, sort_order)
        end
        MC-->>U: 302 → groups#show（参加しました）
    end
```

## 5. 最小送金アルゴリズム（`SettlementService.minimize_transfers`）

```mermaid
flowchart TD
    A["nets: { member => net }"] --> B{"net を分類"}
    B -->|"net > 0"| C["creditors（受取）"]
    B -->|"net < 0"| D["debtors（支払）"]
    C --> E["金額降順ソート<br/>(同額はキーで安定化)"]
    D --> E
    E --> F{"debtors と creditors<br/>両方残っている？"}
    F -->|Yes| G["pay = min(債務, 債権)<br/>transfer: from=debtor → to=creditor"]
    G --> H["両者から pay を減算<br/>0 になった側を次へ"]
    H --> F
    F -->|No| I["transfers を返す（高々 n-1 件）"]
```
