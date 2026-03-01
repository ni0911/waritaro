import type { Sheet, SettlementResult } from "../types";

export function calcSettlement(sheet: Sheet): SettlementResult {
  const splitItems = sheet.items.filter((i) => i.isSplit);

  const totalSplitAmount = splitItems.reduce((sum, i) => sum + i.amount, 0);

  const burden = {
    A: Math.round(totalSplitAmount * (sheet.splitRatio.A / 100)),
    B: Math.round(totalSplitAmount * (sheet.splitRatio.B / 100)),
  };

  const paid = {
    A: splitItems.filter((i) => i.payer === "A").reduce((sum, i) => sum + i.amount, 0),
    B: splitItems.filter((i) => i.payer === "B").reduce((sum, i) => sum + i.amount, 0),
  };

  // diff.A > 0 → Aが払い過ぎ → BがAに支払う
  // diff.A < 0 → Aの支払いが足りない → AがBに支払う
  const diffA = paid.A - burden.A;

  let payer: "A" | "B" | null = null;
  let payee: "A" | "B" | null = null;
  if (diffA < 0) {
    payer = "A";
    payee = "B";
  } else if (diffA > 0) {
    payer = "B";
    payee = "A";
  }

  return {
    totalSplitAmount,
    burden,
    paid,
    diff: Math.abs(diffA),
    payer,
    payee,
  };
}
