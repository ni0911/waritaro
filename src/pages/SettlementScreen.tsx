import { useState } from "react";
import { useParams } from "react-router-dom";
import { Layout } from "../components/Layout";
import { Header } from "../components/Header";
import { useSheet } from "../hooks/useSheets";
import { useCards } from "../hooks/useCards";
import { useSettings } from "../hooks/useSettings";
import { calcSettlement } from "../services/settlementService";
import { generateShareText } from "../services/shareTextService";
import { formatYearMonth } from "../utils/dateUtils";

export function SettlementScreen() {
  const { yearMonth } = useParams<{ yearMonth: string }>();
  const { sheet, loading } = useSheet(yearMonth!);
  const { cards } = useCards();
  const { settings } = useSettings();
  const [copied, setCopied] = useState(false);

  if (loading) {
    return (
      <Layout>
        <Header title="精算結果" back />
        <p className="text-center mt-16 text-gray-400 text-sm">読み込み中...</p>
      </Layout>
    );
  }
  if (!sheet) {
    return (
      <Layout>
        <Header title="精算結果" back />
        <p className="text-center mt-16 text-gray-400 text-sm">シートが見つかりません</p>
      </Layout>
    );
  }

  const result = calcSettlement(sheet);
  const label = (m: "A" | "B") => (m === "A" ? settings.memberA : settings.memberB);

  const handleCopy = async () => {
    const text = generateShareText(sheet, settings, cards);
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <Layout>
      <Header title={`${formatYearMonth(yearMonth!)} 精算結果`} back />
      <div className="px-4 py-6 space-y-4">

        {/* メイン結果カード */}
        <div className="bg-blue-600 rounded-2xl p-6 text-white text-center shadow-lg">
          {result.payer ? (
            <>
              <p className="text-sm opacity-80 mb-1">支払い</p>
              <p className="text-2xl font-bold mb-2">
                {label(result.payer!)} → {label(result.payee!)}
              </p>
              <p className="text-4xl font-bold tracking-tight">
                {result.diff.toLocaleString()}
                <span className="text-2xl ml-1">円</span>
              </p>
            </>
          ) : (
            <>
              <p className="text-2xl font-bold mb-2">🎉 清算なし</p>
              <p className="text-sm opacity-80">差額は0円です</p>
            </>
          )}
        </div>

        {/* 内訳 */}
        <div className="bg-white rounded-xl shadow-sm p-4 space-y-3">
          <p className="text-xs font-bold text-gray-500 uppercase tracking-wide">内訳</p>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">割り勘合計</span>
              <span className="font-semibold">{result.totalSplitAmount.toLocaleString()}円</span>
            </div>
            <hr className="border-gray-100" />
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">{settings.memberA}の負担額（{sheet.splitRatio.A}%）</span>
              <span className="font-semibold">{result.burden.A.toLocaleString()}円</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">{settings.memberB}の負担額（{sheet.splitRatio.B}%）</span>
              <span className="font-semibold">{result.burden.B.toLocaleString()}円</span>
            </div>
            <hr className="border-gray-100" />
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">{settings.memberA}の支払合計</span>
              <span className="font-semibold">{result.paid.A.toLocaleString()}円</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">{settings.memberB}の支払合計</span>
              <span className="font-semibold">{result.paid.B.toLocaleString()}円</span>
            </div>
          </div>
        </div>

        {/* 費用一覧 */}
        <div className="bg-white rounded-xl shadow-sm p-4">
          <p className="text-xs font-bold text-gray-500 uppercase tracking-wide mb-3">費用一覧</p>
          <ul className="space-y-2">
            {sheet.items.map((item) => (
              <li key={item.id} className={`flex justify-between text-sm ${!item.isSplit ? "opacity-40" : ""}`}>
                <span className="text-gray-700">
                  {item.name}
                  {!item.isSplit && <span className="text-xs text-gray-400 ml-1">（私物）</span>}
                </span>
                <span className="font-medium">
                  {label(item.payer)} {item.amount.toLocaleString()}円
                </span>
              </li>
            ))}
          </ul>
        </div>

        {/* LINE共有ボタン */}
        <button
          onClick={handleCopy}
          className={`w-full py-4 rounded-xl font-bold text-sm transition-all ${
            copied
              ? "bg-green-500 text-white"
              : "bg-green-600 text-white active:bg-green-700"
          }`}
        >
          {copied ? "✓ コピーしました！" : "📋 LINE共有用テキストをコピー"}
        </button>
      </div>
    </Layout>
  );
}
