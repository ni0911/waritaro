import { useState, useEffect, useCallback } from "react";
import type { Settings } from "../types";
import { settingsRepository } from "../repository";

export function useSettings() {
  const [settings, setSettings] = useState<Settings>({ memberA: "A", memberB: "B" });
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setSettings(await settingsRepository.get());
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const saveSettings = useCallback(async (s: Settings) => {
    await settingsRepository.save(s);
    await load();
  }, [load]);

  return { settings, loading, saveSettings };
}
