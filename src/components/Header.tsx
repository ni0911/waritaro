import { useNavigate } from "react-router-dom";

interface HeaderProps {
  title: string;
  back?: boolean;
  action?: React.ReactNode;
}

export function Header({ title, back = false, action }: HeaderProps) {
  const navigate = useNavigate();
  return (
    <header className="fixed top-0 left-0 right-0 bg-white border-b border-gray-200 flex items-center h-14 px-4 z-50">
      {back && (
        <button
          onClick={() => navigate(-1)}
          className="mr-3 text-blue-600 text-sm font-medium"
        >
          ← 戻る
        </button>
      )}
      <h1 className="flex-1 text-base font-bold text-gray-900 truncate">{title}</h1>
      {action && <div>{action}</div>}
    </header>
  );
}
