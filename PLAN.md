# 実装計画：同棲支払い管理Webアプリ「ワリタロ会計部」

## 背景・目的

同棲2人の毎月の支払いを管理するWebアプリ。
現状は電卓＋LINEで手計算しているが、以下をシステム化したい。

- 固定費のテンプレート化
- 私物の除外（isSplitフラグ）
- 割り勘計算
- LINE共有

初期はLocalStorageで動かし、将来Supabase移行を見据えたリポジトリパターン設計にする。

---

## 技術スタック

| 層 | 技術 |
|---|---|
| フレームワーク | React + TypeScript + Vite |
| スタイル | Tailwind CSS v3 |
| ルーティング | react-router-dom v6（HashRouter） |
| データ保存 | LocalStorage（将来Supabase移行可） |
| デプロイ | GitHub Pages |

---

## ディレクトリ構成

```
waritaro/
├── src/
│   ├── types/            # 全データモデルの型定義（実装の起点）
│   ├── repository/
│   │   ├── interfaces/   # ICardRepository, ITemplateRepository, ISheetRepository, ISettingsRepository
│   │   ├── localStorage/ # LocalStorage実装（将来 supabase/ に追加するだけ）
│   │   └── index.ts      # DIエントリーポイント（ここだけ変えてSupabase移行）
│   ├── services/         # settlementService.ts, shareTextService.ts
│   ├── hooks/            # useCards, useTemplates, useSheets, useSettings
│   ├── pages/            # 画面単位のコンポーネント
│   ├── components/       # 再利用UIコンポーネント（BottomNav, Headerなど）
│   └── utils/            # dateUtils.ts
```

---

## データモデル

```typescript
// クレジットカード
interface Card {
  id: string;
  name: string;        // 例: "楽天カード"
  owner: "A" | "B";
  createdAt: string;
}

// 固定費テンプレート
interface TemplateItem {
  id: string;
  name: string;        // 例: "家賃"
  amount: number;
  payer: "A" | "B";
  isSplit: boolean;    // 割り勘対象フラグ
  cardId: string | null;
  sortOrder: number;
}

// 月次精算シート
interface Sheet {
  id: string;
  yearMonth: string;   // "2026-03"
  splitRatio: { A: number; B: number };  // 負担比率（合計100）
  items: SheetItem[];
  createdAt: string;
  updatedAt: string;
}

// 精算シートの費用行
interface SheetItem {
  id: string;
  name: string;
  amount: number;
  payer: "A" | "B";
  isSplit: boolean;
  cardId: string | null;
  isFromTemplate: boolean;
  templateItemId: string | null;
}

// 設定（2人の名前カスタマイズ）
interface Settings {
  memberA: string;  // デフォルト: "A"
  memberB: string;  // デフォルト: "B"
}
```

---

## 精算計算ロジック（settlementService.ts）

```
割り勘対象（isSplit: true）の項目のみ集計:
  totalSplitAmount = Σ amount

  burden.A = totalSplitAmount × (splitRatio.A / 100)
  burden.B = totalSplitAmount × (splitRatio.B / 100)

  paid.A = isSplit:true かつ payer:A の合計
  paid.B = isSplit:true かつ payer:B の合計

  diff.A = burden.A - paid.A
  → diff.A > 0 なら A は B に diff.A 円払う
  → diff.A < 0 なら B は A に |diff.A| 円払う
```

---

## 画面一覧と遷移

```
/ （HomeScreen）─ 月一覧・新規作成
  └─ /sheet/:yearMonth （SheetScreen）─ 費用一覧・編集・割り勘フラグ切替
       └─ /sheet/:yearMonth/settlement （SettlementScreen）─ 精算結果・LINEコピー

/templates （TemplateListScreen）
  └─ /templates/:id （TemplateEditScreen）

/cards （CardListScreen）
  └─ /cards/:id （CardEditScreen）

/settings （SettingsScreen）
```

### BottomNav（4タブ）

| タブ | 画面 |
|---|---|
| 今月の支払い | HomeScreen |
| テンプレート | TemplateListScreen |
| カード管理 | CardListScreen |
| 設定 | SettingsScreen |

---

## リポジトリパターン設計

### インターフェース

```typescript
interface ICardRepository {
  findAll(): Promise<Card[]>;
  findById(id: string): Promise<Card | null>;
  save(card: Card): Promise<void>;
  delete(id: string): Promise<void>;
}

interface ITemplateRepository {
  findAll(): Promise<TemplateItem[]>;
  save(item: TemplateItem): Promise<void>;
  delete(id: string): Promise<void>;
  updateOrder(items: TemplateItem[]): Promise<void>;
}

interface ISheetRepository {
  findAll(): Promise<Sheet[]>;
  findByYearMonth(yearMonth: string): Promise<Sheet | null>;
  save(sheet: Sheet): Promise<void>;
  delete(id: string): Promise<void>;
}

interface ISettingsRepository {
  get(): Promise<Settings>;
  save(settings: Settings): Promise<void>;
}
```

### LocalStorage実装の方針
- 全メソッドを `async/await` で統一（Supabase移行時に差し替えやすくする）
- ID生成: `crypto.randomUUID()`
- 日時: ISO8601形式

### Supabase移行時の手順
1. `src/repository/supabase/` に同インターフェースの実装を作成
2. `src/repository/index.ts` の import を差し替えるだけで完了
3. hooks / services の変更は不要

---

## 実装フェーズ

### Phase 1: 基盤（優先度: 最高）
1. Vite + React + TypeScript + Tailwind CSS プロジェクト初期化
2. react-router-dom v6（HashRouter）でルーティング・BottomNav 実装
3. `src/types/` の型定義を全て完成させる
4. リポジトリインターフェースと LocalStorage 実装を全て作成

### Phase 2: カード・テンプレート管理
5. CardListScreen / CardEditScreen
6. TemplateListScreen / TemplateEditScreen

### Phase 3: 月次精算シート
7. HomeScreen（月一覧・新規作成）
8. SheetScreen（テンプレート自動コピー・費用一覧）
9. SheetScreen（追加・削除・フラグ切替・金額編集）
10. クレカ別グループ表示

### Phase 4: 精算・LINE共有
11. settlementService.ts（計算ロジック）
12. SettlementScreen（結果表示）
13. shareTextService.ts（LINE共有テキスト生成・クリップボードコピー）

### Phase 5: 仕上げ・デプロイ
14. スマホUI調整
15. GitHub Pages デプロイ（vite.config.ts の base 設定）
16. GitHub Actions でビルド自動化

---

## UX・デザイン方針

- スマホファーストのモバイルUI
- BottomNav で主要画面へのアクセス
- 割り勘対象外の項目はグレーアウト表示
- クレカ別にグループ表示してカード引き落とし額を確認しやすくする
- LINE共有ボタンでテキストをクリップボードコピー

---

## 未決事項・将来拡張

| 項目 | 状態 |
|---|---|
| ドラッグ&ドロップによるテンプレート並び替え | 将来対応 |
| Supabase移行（複数端末同期） | 将来対応 |
| レシート画像アップロード | 将来対応 |
| 月次サマリーグラフ | 将来対応 |
