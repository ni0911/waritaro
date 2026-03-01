import type { Sheet } from "../../types";
import type { ISheetRepository } from "../interfaces/ISheetRepository";

const KEY = "waritaro:sheets";

export class LocalStorageSheetRepository implements ISheetRepository {
  async findAll(): Promise<Sheet[]> {
    const raw = localStorage.getItem(KEY);
    if (!raw) return [];
    const sheets = JSON.parse(raw) as Sheet[];
    return sheets.sort((a, b) => b.yearMonth.localeCompare(a.yearMonth));
  }

  async findByYearMonth(yearMonth: string): Promise<Sheet | null> {
    const all = await this.findAll();
    return all.find((s) => s.yearMonth === yearMonth) ?? null;
  }

  async save(sheet: Sheet): Promise<void> {
    const all = await this.findAll();
    const index = all.findIndex((s) => s.id === sheet.id);
    if (index >= 0) {
      all[index] = sheet;
    } else {
      all.push(sheet);
    }
    localStorage.setItem(KEY, JSON.stringify(all));
  }

  async delete(id: string): Promise<void> {
    const all = await this.findAll();
    localStorage.setItem(KEY, JSON.stringify(all.filter((s) => s.id !== id)));
  }
}
