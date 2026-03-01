import { useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useTemplates } from "../hooks/useTemplates";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import { generateId } from "../utils/dateUtils";
import type { TemplateItem } from "../types";

export function TemplateListScreen() {
  const navigate = useNavigate();
  const { templates, loading, deleteTemplate, updateOrder } = useTemplates();
  const { cards } = useCards();
  const { settings } = useSettings();

  const label = (m: "A" | "B") => (m === "A" ? settings.memberA : settings.memberB);
  const cardName = (cardId: string | null) =>
    cardId ? (cards.find((c) => c.id === cardId)?.name ?? "不明") : "現金";

  const handleAdd = () => {
    const newItem: TemplateItem = {
      id: generateId(),
      name: "",
      amount: 0,
      payer: "A",
      isSplit: true,
      cardId: null,
      sortOrder: templates.length,
    };
    navigate(`/templates/${newItem.id}`, { state: { item: newItem, isNew: true } });
  };

  const handleDelete = async (item: TemplateItem) => {
    if (!window.confirm(`「${item.name}」を削除しますか？`)) return;
    await deleteTemplate(item.id);
  };

  const handleMoveUp = async (index: number) => {
    if (index === 0) return;
    const reordered = [...templates];
    [reordered[index - 1], reordered[index]] = [reordered[index], reordered[index - 1]];
    await updateOrder(reordered.map((t, i) => ({ ...t, sortOrder: i })));
  };

  const handleMoveDown = async (index: number) => {
    if (index === templates.length - 1) return;
    const reordered = [...templates];
    [reordered[index], reordered[index + 1]] = [reordered[index + 1], reordered[index]];
    await updateOrder(reordered.map((t, i) => ({ ...t, sortOrder: i })));
  };

  return (
    <Layout>
      <Header
        title="固定費テンプレ"
        action={
          <button onClick={handleAdd} className="text-blue-600 font-semibold text-sm">
            ＋追加
          </button>
        }
      />
      <div className="px-4 py-4">
        {loading ? (
          <p className="text-gray-500 text-sm text-center mt-8">読み込み中...</p>
        ) : templates.length === 0 ? (
          <div className="text-center mt-16 text-gray-400">
            <p className="text-4xl mb-3">📋</p>
            <p className="text-sm">テンプレートがまだありません</p>
            <p className="text-xs mt-1">右上の「＋追加」から登録してください</p>
          </div>
        ) : (
          <ul className="space-y-2">
            {templates.map((item, index) => (
              <li
                key={item.id}
                className="bg-white rounded-xl shadow-sm p-4 flex items-center gap-3"
              >
                <div className="flex flex-col gap-1 mr-1">
                  <button
                    onClick={() => handleMoveUp(index)}
                    disabled={index === 0}
                    className="text-gray-400 disabled:opacity-20 text-xs leading-none"
                  >
                    ▲
                  </button>
                  <button
                    onClick={() => handleMoveDown(index)}
                    disabled={index === templates.length - 1}
                    className="text-gray-400 disabled:opacity-20 text-xs leading-none"
                  >
                    ▼
                  </button>
                </div>

                <button
                  onClick={() => navigate(`/templates/${item.id}`, { state: { item, isNew: false } })}
                  className="flex-1 text-left"
                >
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-gray-900">{item.name}</p>
                    <p className="text-sm font-semibold text-gray-700">
                      {item.amount.toLocaleString()}円
                    </p>
                  </div>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-xs text-gray-500">{label(item.payer)}払い</span>
                    <span className="text-xs text-gray-400">•</span>
                    <span className="text-xs text-gray-500">{cardName(item.cardId)}</span>
                    {item.isSplit ? (
                      <span className="text-xs bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">割り勘</span>
                    ) : (
                      <span className="text-xs bg-gray-100 text-gray-500 px-1.5 py-0.5 rounded">私物</span>
                    )}
                  </div>
                </button>

                <button
                  onClick={() => handleDelete(item)}
                  className="text-red-400 text-sm px-2 py-1"
                >
                  削除
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </Layout>
  );
}
