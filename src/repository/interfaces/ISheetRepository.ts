import type { Sheet } from "../../types";

export interface ISheetRepository {
  findAll(): Promise<Sheet[]>;
  findByYearMonth(yearMonth: string): Promise<Sheet | null>;
  save(sheet: Sheet): Promise<void>;
  delete(id: string): Promise<void>;
}
