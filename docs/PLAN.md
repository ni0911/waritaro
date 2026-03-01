# ワリタロ会計部 設計ドキュメント

> 実装済みの設計をまとめたドキュメント。アーキテクチャの詳細は [`adr/`](adr/) も参照。

---

## 背景・目的

同棲2人の毎月の支払いを管理するWebアプリ。
電卓＋LINEでの手計算をシステム化した。

- 固定費のテンプレート化（毎月自動コピー）
- 私物の除外（`isSplit` フラグ）
- 任意比率での割り勘計算
- LINE共有テキストの自動生成

---

## ディレクトリ構成

```
src/
├── types/              # 全データモデルの型定義
├── repository/
│   ├── interfaces/     # ICardRepository, ITemplateRepository, ISheetRepository, ISettingsRepository
│   ├── localStorage/   # LocalStorage実装
│   └── index.ts        # DIエントリーポイント（Supabase移行時はここだけ変更）
├── services/
│   ├── settlementService.ts   # 精算計算ロジック
│   └── shareTextService.ts    # LINE共有テキスト生成
├── hooks/              # useCards, useTemplates, useSheets, useSettings
├── pages/              # 画面単位コンポーネント
├── components/         # BottomNav, Header, Layout
└── utils/              # dateUtils.ts
```

---

## データモデル

```typescript
type Member = "A" | "B";

interface Card {
  id: string;
  name: string;       // 例: "楽天カード"
  owner: Member;
  createdAt: string;
}

interface TemplateItem {
  id: string;
  name: string;       // 例: "家賃"
  amount: number;
  payer: Member;
  isSplit: boolean;   // 割り勘対象フラグ
  cardId: string | null;
  sortOrder: number;
}

interface Sheet {
  id: string;
  yearMonth: string;                   // "2026-03"
  splitRatio: { A: number; B: number }; // 負担比率（合計100）
  items: SheetItem[];
  createdAt: string;
  updatedAt: string;
}

interface SheetItem {
  id: string;
  name: string;
  amount: number;
  payer: Member;
  isSplit: boolean;
  cardId: string | null;
  isFromTemplate: boolean;
  templateItemId: string | null;
}

interface Settings {
  memberA: string;  // デフォルト: "A"
  memberB: string;  // デフォルト: "B"
}
```

---

## 精算計算ロジック

`src/services/settlementService.ts` に実装済み。

```
割り勘対象（isSplit: true）の項目のみ集計:

  totalSplitAmount = Σ amount

  burden.A = totalSplitAmount × (splitRatio.A / 100)
  burden.B = totalSplitAmount × (splitRatio.B / 100)

  paid.A = isSplit:true かつ payer:A の合計
  paid.B = isSplit:true かつ payer:B の合計

  diff.A = paid.A - burden.A
  → diff.A > 0 なら B が A に diff.A 円払う
  → diff.A < 0 なら A が B に |diff.A| 円払う
```

---

## 画面構成・ルーティング

```
/ （HomeScreen）
  └─ /sheet/:yearMonth （SheetScreen）
       └─ /sheet/:yearMonth/settlement （SettlementScreen）

/templates （TemplateListScreen）
  └─ /templates/:id （TemplateEditScreen）

/cards （CardListScreen）
  └─ /cards/:id （CardEditScreen）

/settings （SettingsScreen）
```

### BottomNav

| タブ | 遷移先 |
|------|--------|
| 支払い | HomeScreen |
| テンプレ | TemplateListScreen |
| カード | CardListScreen |
| 設定 | SettingsScreen |

---

## Supabase 移行手順（将来）

1. `src/repository/supabase/` に各インターフェースの実装を作成
2. `src/repository/index.ts` の import を差し替えるだけで完了
3. hooks / services / pages の変更は不要

ID は `crypto.randomUUID()`、日時は ISO8601 で統一済みのため、データ形式の変換も不要。

---

## 将来拡張候補

| 項目 | 状態 |
|------|------|
| ドラッグ&ドロップによるテンプレート並び替え | 未対応（現在は▲▼ボタン） |
| Supabase 移行（複数端末同期） | 未対応 |
| レシート画像アップロード | 未対応 |
| 月次サマリーグラフ | 未対応 |
