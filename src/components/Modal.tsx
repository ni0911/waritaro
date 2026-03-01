import { useState, useEffect } from "react";

interface ConfirmModalProps {
  message: string;
  onConfirm: () => void;
  onCancel: () => void;
  confirmLabel?: string;
  destructive?: boolean;
}

export function ConfirmModal({
  message,
  onConfirm,
  onCancel,
  confirmLabel = "OK",
  destructive = false,
}: ConfirmModalProps) {
  return (
    <div className="fixed inset-0 z-[100] flex items-end justify-center sm:items-center">
      <div className="absolute inset-0 bg-black/40" onClick={onCancel} />
      <div className="relative bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-sm p-6 safe-area-bottom">
        <p className="text-sm text-gray-800 text-center mb-6 leading-relaxed">{message}</p>
        <div className="flex gap-3">
          <button
            onClick={onCancel}
            className="flex-1 py-3 rounded-xl border border-gray-300 text-sm font-medium text-gray-700"
          >
            キャンセル
          </button>
          <button
            onClick={onConfirm}
            className={`flex-1 py-3 rounded-xl text-sm font-bold text-white ${
              destructive ? "bg-red-500" : "bg-blue-600"
            }`}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  );
}

interface PromptModalProps {
  message: string;
  defaultValue?: string;
  placeholder?: string;
  inputMode?: React.HTMLAttributes<HTMLInputElement>["inputMode"];
  onConfirm: (value: string) => void;
  onCancel: () => void;
}

export function PromptModal({
  message,
  defaultValue = "",
  placeholder = "",
  inputMode = "text",
  onConfirm,
  onCancel,
}: PromptModalProps) {
  const [value, setValue] = useState(defaultValue);

  useEffect(() => {
    setValue(defaultValue);
  }, [defaultValue]);

  return (
    <div className="fixed inset-0 z-[100] flex items-end justify-center sm:items-center">
      <div className="absolute inset-0 bg-black/40" onClick={onCancel} />
      <div className="relative bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-sm p-6 safe-area-bottom">
        <p className="text-sm font-medium text-gray-800 mb-3">{message}</p>
        <input
          type="text"
          value={value}
          onChange={(e) => setValue(e.target.value)}
          placeholder={placeholder}
          inputMode={inputMode}
          autoFocus
          className="w-full border border-gray-300 rounded-xl px-4 py-3 text-base focus:outline-none focus:ring-2 focus:ring-blue-400 mb-4"
        />
        <div className="flex gap-3">
          <button
            onClick={onCancel}
            className="flex-1 py-3 rounded-xl border border-gray-300 text-sm font-medium text-gray-700"
          >
            キャンセル
          </button>
          <button
            onClick={() => onConfirm(value)}
            className="flex-1 py-3 rounded-xl bg-blue-600 text-white text-sm font-bold"
          >
            OK
          </button>
        </div>
      </div>
    </div>
  );
}
