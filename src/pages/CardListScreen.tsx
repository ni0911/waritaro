import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { ConfirmModal } from "../components/Modal";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import type { Card } from "../types";

export function CardListScreen() {
  const navigate = useNavigate();
  const { cards, loading, deleteCard } = useCards();
  const { settings } = useSettings();
  const [deleteTarget, setDeleteTarget] = useState<Card | null>(null);

  const label = (owner: "A" | "B") =>
    owner === "A" ? settings.memberA : settings.memberB;

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return;
    await deleteCard(deleteTarget.id);
    setDeleteTarget(null);
  };

  return (
    <Layout>
      <Header
        title="カード管理"
        action={
          <button
            onClick={() => navigate("/cards/new")}
            className="text-blue-600 font-semibold text-sm py-2 px-2"
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
                  onClick={() => setDeleteTarget(card)}
                  className="text-red-400 text-sm ml-4 py-2 px-3"
                >
                  削除
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      {deleteTarget && (
        <ConfirmModal
          message={`「${deleteTarget.name}」を削除しますか？`}
          confirmLabel="削除"
          destructive
          onConfirm={handleDeleteConfirm}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </Layout>
  );
}
