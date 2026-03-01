import { useState, useEffect } from "react";
import { useParams, useNavigate, useLocation } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useTemplates } from "../hooks/useTemplates";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import type { TemplateItem, Member } from "../types";
import { generateId } from "../utils/dateUtils";

export function TemplateEditScreen() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const location = useLocation();
  const { templates, saveTemplate } = useTemplates();
  const { cards } = useCards();
  const { settings } = useSettings();

  const locationItem = (location.state as { item?: TemplateItem; isNew?: boolean } | null)?.item;
  const isNew = (location.state as { isNew?: boolean } | null)?.isNew ?? false;

  const existing = locationItem ?? templates.find((t) => t.id === id);

  const [name, setName] = useState(existing?.name ?? "");
  const [amount, setAmount] = useState(existing?.amount?.toString() ?? "");
  const [payer, setPayer] = useState<Member>(existing?.payer ?? "A");
  const [isSplit, setIsSplit] = useState(existing?.isSplit ?? true);
  const [cardId, setCardId] = useState<string | null>(existing?.cardId ?? null);

  useEffect(() => {
    if (existing) {
      setName(existing.name);
      setAmount(existing.amount.toString());
      setPayer(existing.payer);
      setIsSplit(existing.isSplit);
      setCardId(existing.cardId);
    }
  }, []);

  const handleSave = async () => {
    if (!name.trim()) { alert("項目名を入力してください"); return; }
    const amountNum = parseInt(amount, 10);
    if (isNaN(amountNum) || amountNum < 0) { alert("金額を正しく入力してください"); return; }

    const item: TemplateItem = {
      id: isNew ? (id ?? generateId()) : (id!),
      name: name.trim(),
      amount: amountNum,
      payer,
      isSplit,
      cardId,
      sortOrder: existing?.sortOrder ?? templates.length,
    };
    await saveTemplate(item);
    navigate("/templates");
  };

  return (
    <Layout>
      <Header title={isNew ? "テンプレ追加" : "テンプレ編集"} back />
      <div className="px-4 py-6 space-y-5">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">項目名</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="例: 家賃"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">金額（円）</label>
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            inputMode="numeric"
            placeholder="0"
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">支払い者</label>
          <div className="flex gap-3">
            {(["A", "B"] as Member[]).map((m) => (
              <button
                key={m}
                onClick={() => setPayer(m)}
                className={`flex-1 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                  payer === m
                    ? "bg-blue-600 border-blue-600 text-white"
                    : "bg-white border-gray-300 text-gray-700"
                }`}
              >
                {m === "A" ? settings.memberA : settings.memberB}
              </button>
            ))}
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">割り勘対象</label>
          <div className="flex gap-3">
            <button
              onClick={() => setIsSplit(true)}
              className={`flex-1 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                isSplit ? "bg-blue-600 border-blue-600 text-white" : "bg-white border-gray-300 text-gray-700"
              }`}
            >
              割り勘
            </button>
            <button
              onClick={() => setIsSplit(false)}
              className={`flex-1 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                !isSplit ? "bg-orange-500 border-orange-500 text-white" : "bg-white border-gray-300 text-gray-700"
              }`}
            >
              私物（対象外）
            </button>
          </div>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">使用カード</label>
          <select
            value={cardId ?? ""}
            onChange={(e) => setCardId(e.target.value || null)}
            className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-400 bg-white"
          >
            <option value="">現金</option>
            {cards.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}（{c.owner === "A" ? settings.memberA : settings.memberB}）
              </option>
            ))}
          </select>
        </div>

        <button
          onClick={handleSave}
          className="w-full bg-blue-600 text-white rounded-xl py-3 font-semibold text-sm mt-4"
        >
          保存
        </button>
      </div>
    </Layout>
  );
}
