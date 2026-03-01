import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { ConfirmModal, PromptModal } from "../components/Modal";
import { useSheets } from "../hooks/useSheets";
import { useTemplates } from "../hooks/useTemplates";
import { formatYearMonth, getCurrentYearMonth, generateId, nowISO } from "../utils/dateUtils";
import type { Sheet, SheetItem } from "../types";

export function HomeScreen() {
  const navigate = useNavigate();
  const { sheets, loading, saveSheet, deleteSheet } = useSheets();
  const { templates } = useTemplates();
  const [creating, setCreating] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState<Sheet | null>(null);
  const [createError, setCreateError] = useState("");

  const handleCreateConfirm = async (yearMonth: string) => {
    if (!yearMonth.match(/^\d{4}-\d{2}$/)) {
      setCreateError("形式が正しくありません（例: 2026-03）");
      return;
    }
    if (sheets.some((s) => s.yearMonth === yearMonth)) {
      setCreateError(`${formatYearMonth(yearMonth)} のシートはすでにあります`);
      return;
    }
    setShowCreateModal(false);
    setCreateError("");
    setCreating(true);

    const items: SheetItem[] = templates.map((t) => ({
      id: generateId(),
      name: t.name,
      amount: t.amount,
      payer: t.payer,
      isSplit: t.isSplit,
      cardId: t.cardId,
      isFromTemplate: true,
      templateItemId: t.id,
    }));

    const sheet: Sheet = {
      id: generateId(),
      yearMonth,
      splitRatio: { A: 50, B: 50 },
      items,
      createdAt: nowISO(),
      updatedAt: nowISO(),
    };

    await saveSheet(sheet);
    setCreating(false);
    navigate(`/sheet/${yearMonth}`);
  };

  const handleDeleteConfirm = async () => {
    if (!deleteTarget) return;
    await deleteSheet(deleteTarget.id);
    setDeleteTarget(null);
  };

  return (
    <Layout>
      <Header
        title="ワリタロ会計部"
        action={
          <button
            onClick={() => { setShowCreateModal(true); setCreateError(""); }}
            disabled={creating}
            className="text-blue-600 font-semibold text-sm py-2 px-2 disabled:opacity-50"
          >
            ＋新規
          </button>
        }
      />
      <div className="px-4 py-4">
        {loading ? (
          <p className="text-gray-500 text-sm text-center mt-8">読み込み中...</p>
        ) : sheets.length === 0 ? (
          <div className="text-center mt-16 text-gray-400">
            <p className="text-5xl mb-4">💰</p>
            <p className="text-sm font-medium">まだシートがありません</p>
            <p className="text-xs mt-1">右上の「＋新規」から月次シートを作成してください</p>
          </div>
        ) : (
          <ul className="space-y-3">
            {sheets.map((sheet) => {
              const total = sheet.items
                .filter((i) => i.isSplit)
                .reduce((s, i) => s + i.amount, 0);
              return (
                <li key={sheet.id} className="bg-white rounded-xl shadow-sm overflow-hidden">
                  <button
                    onClick={() => navigate(`/sheet/${sheet.yearMonth}`)}
                    className="w-full text-left p-4"
                  >
                    <div className="flex items-center justify-between">
                      <p className="font-bold text-gray-900 text-base">
                        {formatYearMonth(sheet.yearMonth)}
                      </p>
                      <p className="text-sm text-blue-600 font-semibold">
                        割り勘合計 {total.toLocaleString()}円
                      </p>
                    </div>
                    <p className="text-xs text-gray-400 mt-1">{sheet.items.length}件の費用</p>
                  </button>
                  <div className="border-t border-gray-100 flex">
                    <button
                      onClick={() => navigate(`/sheet/${sheet.yearMonth}/settlement`)}
                      className="flex-1 py-3 text-xs text-blue-600 font-medium"
                    >
                      精算結果を見る
                    </button>
                    <div className="w-px bg-gray-100" />
                    <button
                      onClick={() => setDeleteTarget(sheet)}
                      className="px-5 py-3 text-xs text-red-400"
                    >
                      削除
                    </button>
                  </div>
                </li>
              );
            })}
          </ul>
        )}
      </div>

      {showCreateModal && (
        <PromptModal
          message="作成する年月を入力"
          defaultValue={getCurrentYearMonth()}
          placeholder="例: 2026-03"
          inputMode="numeric"
          onConfirm={handleCreateConfirm}
          onCancel={() => { setShowCreateModal(false); setCreateError(""); }}
        />
      )}
      {createError && (
        <ConfirmModal
          message={createError}
          confirmLabel="OK"
          onConfirm={() => setCreateError("")}
          onCancel={() => setCreateError("")}
        />
      )}
      {deleteTarget && (
        <ConfirmModal
          message={`${formatYearMonth(deleteTarget.yearMonth)} を削除しますか？`}
          confirmLabel="削除"
          destructive
          onConfirm={handleDeleteConfirm}
          onCancel={() => setDeleteTarget(null)}
        />
      )}
    </Layout>
  );
}
