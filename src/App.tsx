import { HashRouter, Routes, Route } from "react-router-dom";
import { HomeScreen } from "./pages/HomeScreen";
import { SheetScreen } from "./pages/SheetScreen";
import { SettlementScreen } from "./pages/SettlementScreen";
import { TemplateListScreen } from "./pages/TemplateListScreen";
import { TemplateEditScreen } from "./pages/TemplateEditScreen";
import { CardListScreen } from "./pages/CardListScreen";
import { CardEditScreen } from "./pages/CardEditScreen";
import { SettingsScreen } from "./pages/SettingsScreen";

export default function App() {
  return (
    <HashRouter>
      <Routes>
        <Route path="/" element={<HomeScreen />} />
        <Route path="/sheet/:yearMonth" element={<SheetScreen />} />
        <Route path="/sheet/:yearMonth/settlement" element={<SettlementScreen />} />
        <Route path="/templates" element={<TemplateListScreen />} />
        <Route path="/templates/:id" element={<TemplateEditScreen />} />
        <Route path="/cards" element={<CardListScreen />} />
        <Route path="/cards/:id" element={<CardEditScreen />} />
        <Route path="/settings" element={<SettingsScreen />} />
      </Routes>
    </HashRouter>
  );
}
