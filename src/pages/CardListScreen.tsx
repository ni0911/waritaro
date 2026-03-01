import { useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import { generateId, nowISO } from "../utils/dateUtils";
import type { Card } from "../types";

export function CardListScreen() {
  const navigate = useNavigate();
  const { cards, loading, saveCard, deleteCard } = useCards();
  const { settings } = useSettings();

  const label = (owner: "A" | "B") =>
    owner === "A" ? settings.memberA : settings.memberB;

  const handleAdd = async () => {
    const name = window.prompt("カード名を入力してください");
    if (!name?.trim()) return;
    const owner = window.confirm(`${settings.memberA}のカードですか？\n（キャンセルで${settings.memberB}）`)
      ? "A" as const
      : "B" as const;
    const card: Card = {
      id: generateId(),
      name: name.trim(),
      owner,
      createdAt: nowISO(),
    };
    await saveCard(card);
  };

  const handleDelete = async (card: Card) => {
    if (!window.confirm(`「${card.name}」を削除しますか？`)) return;
    await deleteCard(card.id);
  };

  return (
    <Layout>
      <Header
        title="カード管理"
        action={
          <button
            onClick={handleAdd}
            className="text-blue-600 font-semibold text-sm"
          >
            ＋追加
          </button>
        }
      />
      <div className="px-4 py-4">
        {loading ? (
          <p className="text-gray-500 text-sm text-center mt-8">読み込み中...</p>
        ) : cards.length === 0 ? (
          <div className="text-center mt-16 text-gray-400">
            <p className="text-4xl mb-3">💳</p>
            <p className="text-sm">カードがまだありません</p>
            <p className="text-xs mt-1">右上の「＋追加」から登録してください</p>
          </div>
        ) : (
          <ul className="space-y-2">
            {cards.map((card) => (
              <li
                key={card.id}
                className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between"
              >
                <button
                  onClick={() => navigate(`/cards/${card.id}`)}
                  className="flex-1 text-left"
                >
                  <p className="font-medium text-gray-900">{card.name}</p>
                  <p className="text-xs text-gray-500 mt-0.5">{label(card.owner)}のカード</p>
                </button>
                <button
                  onClick={() => handleDelete(card)}
                  className="text-red-400 text-sm ml-4 px-2 py-1"
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
