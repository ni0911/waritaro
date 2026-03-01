import { NavLink } from "react-router-dom";

const tabs = [
  { to: "/", label: "支払い", icon: "💳" },
  { to: "/templates", label: "テンプレ", icon: "📋" },
  { to: "/cards", label: "カード", icon: "💴" },
  { to: "/settings", label: "設定", icon: "⚙️" },
];

export function BottomNav() {
  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex z-50">
      {tabs.map((tab) => (
        <NavLink
          key={tab.to}
          to={tab.to}
          end={tab.to === "/"}
          className={({ isActive }) =>
            `flex-1 flex flex-col items-center justify-center py-2 text-xs gap-0.5 transition-colors ${
              isActive ? "text-blue-600 font-semibold" : "text-gray-500"
            }`
          }
        >
          <span className="text-xl">{tab.icon}</span>
          <span>{tab.label}</span>
        </NavLink>
      ))}
    </nav>
  );
}
