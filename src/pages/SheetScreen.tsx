import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useSheet } from "../hooks/useSheets";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import { formatYearMonth, generateId, nowISO } from "../utils/dateUtils";
import type { SheetItem, Member } from "../types";

export function SheetScreen() {
  const { yearMonth } = useParams<{ yearMonth: string }>();
  const navigate = useNavigate();
  const { sheet, loading, saveSheet } = useSheet(yearMonth!);
  const { cards } = useCards();
  const { settings } = useSettings();

  const [showAddForm, setShowAddForm] = useState(false);
  const [newName, setNewName] = useState("");
  const [newAmount, setNewAmount] = useState("");
  const [newPayer, setNewPayer] = useState<Member>("A");
  const [newIsSplit, setNewIsSplit] = useState(true);
  const [newCardId, setNewCardId] = useState<string | null>(null);

  if (loading) {
    return (
      <Layout>
        <Header title="読み込み中..." back />
        <p className="text-center mt-16 text-gray-400 text-sm">読み込み中...</p>
      </Layout>
    );
  }
  if (!sheet) {
    return (
      <Layout>
        <Header title="シートが見つかりません" back />
        <p className="text-center mt-16 text-gray-400 text-sm">シートが見つかりません</p>
      </Layout>
    );
  }

  const label = (m: Member) => (m === "A" ? settings.memberA : settings.memberB);
  const cardName = (id: string | null) =>
    id ? (cards.find((c) => c.id === id)?.name ?? "不明") : "現金";

  const updateSheet = async (items: SheetItem[]) => {
    await saveSheet({ ...sheet, items, updatedAt: nowISO() });
  };

  const handleToggleSplit = async (itemId: string) => {
    const items = sheet.items.map((i) =>
      i.id === itemId ? { ...i, isSplit: !i.isSplit } : i
    );
    await updateSheet(items);
  };

  const handleEditAmount = async (item: SheetItem) => {
    const val = window.prompt(`「${item.name}」の金額を入力`, item.amount.toString());
    if (val === null) return;
    const num = parseInt(val, 10);
    if (isNaN(num) || num < 0) { alert("正しい金額を入力してください"); return; }
    const items = sheet.items.map((i) => (i.id === item.id ? { ...i, amount: num } : i));
    await updateSheet(items);
  };

  const handleDelete = async (itemId: string) => {
    const items = sheet.items.filter((i) => i.id !== itemId);
    await updateSheet(items);
  };

  const handleAddItem = async () => {
    if (!newName.trim()) { alert("項目名を入力してください"); return; }
    const amountNum = parseInt(newAmount, 10);
    if (isNaN(amountNum) || amountNum < 0) { alert("金額を正しく入力してください"); return; }
    const newItem: SheetItem = {
      id: generateId(),
      name: newName.trim(),
      amount: amountNum,
      payer: newPayer,
      isSplit: newIsSplit,
      cardId: newCardId,
      isFromTemplate: false,
      templateItemId: null,
    };
    await updateSheet([...sheet.items, newItem]);
    setNewName("");
    setNewAmount("");
    setNewPayer("A");
    setNewIsSplit(true);
    setNewCardId(null);
    setShowAddForm(false);
  };

  const handleRatioChange = async (ratioA: number) => {
    const ratioB = 100 - ratioA;
    await saveSheet({ ...sheet, splitRatio: { A: ratioA, B: ratioB }, updatedAt: nowISO() });
  };

  // クレカ別グループ表示のため、カードIDでグループ化
  const grouped = new Map<string, SheetItem[]>();
  for (const item of sheet.items) {
    const key = item.cardId ?? "__cash__";
    if (!grouped.has(key)) grouped.set(key, []);
    grouped.get(key)!.push(item);
  }

  return (
    <Layout>
      <Header
        title={formatYearMonth(yearMonth!)}
        back
        action={
          <button
            onClick={() => navigate(`/sheet/${yearMonth}/settlement`)}
            className="text-blue-600 font-semibold text-sm"
          >
            精算 →
          </button>
        }
      />
      <div className="px-4 py-4 space-y-4">

        {/* 負担比率設定 */}
        <div className="bg-white rounded-xl shadow-sm p-4">
          <p className="text-xs font-semibold text-gray-500 mb-2">負担比率</p>
          <div className="flex items-center gap-3">
            <span className="text-sm font-medium w-16">{settings.memberA}: {sheet.splitRatio.A}%</span>
            <input
              type="range"
              min={0}
              max={100}
              step={5}
              value={sheet.splitRatio.A}
              onChange={(e) => handleRatioChange(Number(e.target.value))}
              className="flex-1"
            />
            <span className="text-sm font-medium w-16 text-right">{settings.memberB}: {sheet.splitRatio.B}%</span>
          </div>
        </div>

        {/* カード別グループ表示 */}
        {Array.from(grouped.entries()).map(([key, items]) => {
          const groupCard = key === "__cash__" ? null : cards.find((c) => c.id === key);
          const groupTotal = items.filter((i) => i.isSplit).reduce((s, i) => s + i.amount, 0);
          return (
            <div key={key} className="bg-white rounded-xl shadow-sm overflow-hidden">
              <div className="px-4 py-2 bg-gray-50 border-b border-gray-100 flex items-center justify-between">
                <p className="text-xs font-bold text-gray-600">
                  {groupCard ? `${groupCard.name}（${label(groupCard.owner)}）` : "現金"}
                </p>
                {groupTotal > 0 && (
                  <p className="text-xs text-blue-600 font-medium">割り勘 {groupTotal.toLocaleString()}円</p>
                )}
              </div>
              <ul className="divide-y divide-gray-50">
                {items.map((item) => (
                  <li key={item.id} className={`px-4 py-3 flex items-center gap-2 ${!item.isSplit ? "opacity-50" : ""}`}>
                    <button
                      onClick={() => handleToggleSplit(item.id)}
                      className={`w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                        item.isSplit
                          ? "bg-blue-600 border-blue-600 text-white"
                          : "border-gray-300 text-transparent"
                      }`}
                    >
                      ✓
                    </button>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">{item.name}</p>
                      <p className="text-xs text-gray-500">{label(item.payer)}払い · {cardName(item.cardId)}</p>
                    </div>
                    <button
                      onClick={() => handleEditAmount(item)}
                      className="text-sm font-semibold text-gray-700 tabular-nums"
                    >
                      {item.amount.toLocaleString()}円
                    </button>
                    <button
                      onClick={() => handleDelete(item.id)}
                      className="text-red-400 text-xs px-1.5 py-1 ml-1"
                    >
                      削除
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          );
        })}

        {/* 追加フォーム */}
        {showAddForm ? (
          <div className="bg-white rounded-xl shadow-sm p-4 space-y-3">
            <p className="text-sm font-semibold text-gray-700">費用を追加</p>
            <input
              type="text"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              placeholder="項目名"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
            <input
              type="number"
              value={newAmount}
              onChange={(e) => setNewAmount(e.target.value)}
              inputMode="numeric"
              placeholder="金額（円）"
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
            <div className="flex gap-2">
              {(["A", "B"] as Member[]).map((m) => (
                <button
                  key={m}
                  onClick={() => setNewPayer(m)}
                  className={`flex-1 py-2 rounded-lg border text-sm font-medium transition-colors ${
                    newPayer === m
                      ? "bg-blue-600 border-blue-600 text-white"
                      : "bg-white border-gray-300 text-gray-700"
                  }`}
                >
                  {label(m)}払い
                </button>
              ))}
            </div>
            <div className="flex gap-2">
              <button
                onClick={() => setNewIsSplit(true)}
                className={`flex-1 py-2 rounded-lg border text-sm font-medium transition-colors ${
                  newIsSplit ? "bg-blue-600 border-blue-600 text-white" : "bg-white border-gray-300 text-gray-700"
                }`}
              >
                割り勘
              </button>
              <button
                onClick={() => setNewIsSplit(false)}
                className={`flex-1 py-2 rounded-lg border text-sm font-medium transition-colors ${
                  !newIsSplit ? "bg-orange-500 border-orange-500 text-white" : "bg-white border-gray-300 text-gray-700"
                }`}
              >
                私物
              </button>
            </div>
            <select
              value={newCardId ?? ""}
              onChange={(e) => setNewCardId(e.target.value || null)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm bg-white focus:outline-none focus:ring-2 focus:ring-blue-400"
            >
              <option value="">現金</option>
              {cards.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}（{label(c.owner)}）
                </option>
              ))}
            </select>
            <div className="flex gap-2 pt-1">
              <button
                onClick={() => setShowAddForm(false)}
                className="flex-1 py-2.5 rounded-xl border border-gray-300 text-sm text-gray-600"
              >
                キャンセル
              </button>
              <button
                onClick={handleAddItem}
                className="flex-1 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-semibold"
              >
                追加
              </button>
            </div>
          </div>
        ) : (
          <button
            onClick={() => setShowAddForm(true)}
            className="w-full py-3 rounded-xl border-2 border-dashed border-gray-300 text-gray-500 text-sm font-medium"
          >
            ＋ 費用を追加
          </button>
        )}
      </div>
    </Layout>
  );
}
