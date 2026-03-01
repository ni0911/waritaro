import { useState, useEffect } from "react";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useSettings } from "../hooks/useSettings";

export function SettingsScreen() {
  const { settings, loading, saveSettings } = useSettings();
  const [memberA, setMemberA] = useState(settings.memberA);
  const [memberB, setMemberB] = useState(settings.memberB);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    setMemberA(settings.memberA);
    setMemberB(settings.memberB);
  }, [settings]);

  const handleSave = async () => {
    if (!memberA.trim() || !memberB.trim()) {
      alert("名前を入力してください");
      return;
    }
    await saveSettings({ memberA: memberA.trim(), memberB: memberB.trim() });
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <Layout>
      <Header title="設定" />
      <div className="px-4 py-6 space-y-6">
        <div className="bg-white rounded-xl shadow-sm p-4 space-y-4">
          <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">メンバー名</p>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">メンバーA の名前</label>
            <input
              type="text"
              value={memberA}
              onChange={(e) => setMemberA(e.target.value)}
              placeholder="例: たろう"
              disabled={loading}
              className="w-full border border-gray-300 rounded-xl px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">メンバーB の名前</label>
            <input
              type="text"
              value={memberB}
              onChange={(e) => setMemberB(e.target.value)}
              placeholder="例: はなこ"
              disabled={loading}
              className="w-full border border-gray-300 rounded-xl px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-blue-400"
            />
          </div>
          <p className="text-xs text-gray-400">
            ここで設定した名前が全画面・LINE共有テキストに反映されます
          </p>
        </div>

        <button
          onClick={handleSave}
          disabled={loading}
          className={`w-full py-3 rounded-xl font-semibold text-sm transition-all ${
            saved ? "bg-green-500 text-white" : "bg-blue-600 text-white active:bg-blue-700"
          } disabled:opacity-50`}
        >
          {saved ? "✓ 保存しました" : "保存"}
        </button>

        <div className="text-center text-xs text-gray-300 mt-8">
          ワリタロ会計部
        </div>
      </div>
    </Layout>
  );
}
