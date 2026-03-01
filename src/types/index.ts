export type Member = "A" | "B";

export interface Card {
  id: string;
  name: string;
  owner: Member;
  createdAt: string;
}

export interface TemplateItem {
  id: string;
  name: string;
  amount: number;
  payer: Member;
  isSplit: boolean;
  cardId: string | null;
  sortOrder: number;
}

export interface SheetItem {
  id: string;
  name: string;
  amount: number;
  payer: Member;
  isSplit: boolean;
  cardId: string | null;
  isFromTemplate: boolean;
  templateItemId: string | null;
}

export interface Sheet {
  id: string;
  yearMonth: string;
  splitRatio: { A: number; B: number };
  items: SheetItem[];
  createdAt: string;
  updatedAt: string;
}

export interface Settings {
  memberA: string;
  memberB: string;
}

export interface SettlementResult {
  totalSplitAmount: number;
  burden: { A: number; B: number };
  paid: { A: number; B: number };
  diff: number;
  payer: Member | null;
  payee: Member | null;
}
