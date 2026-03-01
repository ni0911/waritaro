// DIエントリーポイント
// Supabase移行時はここのimportを差し替えるだけでOK
import { LocalStorageCardRepository } from "./localStorage/LocalStorageCardRepository";
import { LocalStorageTemplateRepository } from "./localStorage/LocalStorageTemplateRepository";
import { LocalStorageSheetRepository } from "./localStorage/LocalStorageSheetRepository";
import { LocalStorageSettingsRepository } from "./localStorage/LocalStorageSettingsRepository";

export const cardRepository = new LocalStorageCardRepository();
export const templateRepository = new LocalStorageTemplateRepository();
export const sheetRepository = new LocalStorageSheetRepository();
export const settingsRepository = new LocalStorageSettingsRepository();
