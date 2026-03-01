import { useState, useEffect, useCallback } from "react";
import type { Sheet } from "../types";
import { sheetRepository } from "../repository";

export function useSheets() {
  const [sheets, setSheets] = useState<Sheet[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setSheets(await sheetRepository.findAll());
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const saveSheet = useCallback(async (sheet: Sheet) => {
    await sheetRepository.save(sheet);
    await load();
  }, [load]);

  const deleteSheet = useCallback(async (id: string) => {
    await sheetRepository.delete(id);
    await load();
  }, [load]);

  return { sheets, loading, saveSheet, deleteSheet, reload: load };
}

export function useSheet(yearMonth: string) {
  const [sheet, setSheet] = useState<Sheet | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setSheet(await sheetRepository.findByYearMonth(yearMonth));
    setLoading(false);
  }, [yearMonth]);

  useEffect(() => {
    load();
  }, [load]);

  const saveSheet = useCallback(async (s: Sheet) => {
    await sheetRepository.save(s);
    await load();
  }, [load]);

  return { sheet, loading, saveSheet, reload: load };
}
