import type { Sheet, Settings, Card } from "../types";
import { calcSettlement } from "./settlementService";
import { formatYearMonth } from "../utils/dateUtils";

export function generateShareText(sheet: Sheet, settings: Settings, cards: Card[]): string {
  const { memberA, memberB } = settings;
  const result = calcSettlement(sheet);
  const label = (m: "A" | "B") => (m === "A" ? memberA : memberB);

  const cardName = (cardId: string | null): string => {
    if (!cardId) return "現金";
    return cards.find((c) => c.id === cardId)?.name ?? "不明カード";
  };

  const lines: string[] = [];
  lines.push(`【${formatYearMonth(sheet.yearMonth)} 精算】`);
  lines.push("");

  // 割り勘対象
  const splitItems = sheet.items.filter((i) => i.isSplit);
  if (splitItems.length > 0) {
    lines.push("■ 割り勘対象");
    for (const item of splitItems) {
      lines.push(`  ${item.name}：${item.amount.toLocaleString()}円（${label(item.payer)}払い）`);
    }
    lines.push(`  合計：${result.totalSplitAmount.toLocaleString()}円`);
    lines.push("");
  }

  // 私物（割り勘対象外）
  const privateItems = sheet.items.filter((i) => !i.isSplit);
  if (privateItems.length > 0) {
    lines.push("■ 私物（対象外）");
    for (const item of privateItems) {
      lines.push(`  ${item.name}：${item.amount.toLocaleString()}円（${label(item.payer)}払い / ${cardName(item.cardId)}）`);
    }
    lines.push("");
  }

  // 負担額
  lines.push("■ 負担比率");
  lines.push(`  ${memberA}：${sheet.splitRatio.A}%（${result.burden.A.toLocaleString()}円）`);
  lines.push(`  ${memberB}：${sheet.splitRatio.B}%（${result.burden.B.toLocaleString()}円）`);
  lines.push("");

  // 精算結果
  lines.push("■ 精算");
  if (result.payer && result.payee) {
    lines.push(`  ${label(result.payer)} → ${label(result.payee)} へ ${result.diff.toLocaleString()}円`);
  } else {
    lines.push("  清算なし（差額なし）");
  }

  return lines.join("\n");
}
