import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import { generateId, nowISO } from "../utils/dateUtils";
import type { Card, Member } from "../types";

export function CardEditScreen() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { cards, saveCard } = useCards();
  const { settings } = useSettings();

  const isNew = id === "new";
  const existing = cards.find((c) => c.id === id);

  const [name, setName] = useState("");
  const [owner, setOwner] = useState<Member>("A");

  useEffect(() => {
    if (existing) {
      setName(existing.name);
      setOwner(existing.owner);
    }
  }, [existing]);

  const handleSave = async () => {
    if (!name.trim()) {
      alert("カード名を入力してください");
      return;
    }
    const card: Card = {
      id: isNew ? generateId() : id!,
      name: name.trim(),
      owner,
      createdAt: existing?.createdAt ?? nowISO(),
    };
    await saveCard(card);
    navigate("/cards");
  };

  return (
    <Layout>
      <Header title={isNew ? "カード追加" : "カード編集"} back />
      <div className="px-4 py-6 space-y-5">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">カード名</label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="例: 楽天カード"
            className="w-full border border-gray-300 rounded-xl px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-blue-400"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">持ち主</label>
          <div className="flex gap-3">
            {(["A", "B"] as Member[]).map((m) => (
              <button
                key={m}
                onClick={() => setOwner(m)}
                className={`flex-1 py-2.5 rounded-lg border text-sm font-medium transition-colors ${
                  owner === m
                    ? "bg-blue-600 border-blue-600 text-white"
                    : "bg-white border-gray-300 text-gray-700"
                }`}
              >
                {m === "A" ? settings.memberA : settings.memberB}
              </button>
            ))}
          </div>
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
