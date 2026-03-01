import type { Settings } from "../../types";
import type { ISettingsRepository } from "../interfaces/ISettingsRepository";

const KEY = "waritaro:settings";
const DEFAULT_SETTINGS: Settings = { memberA: "A", memberB: "B" };

export class LocalStorageSettingsRepository implements ISettingsRepository {
  async get(): Promise<Settings> {
    const raw = localStorage.getItem(KEY);
    if (!raw) return { ...DEFAULT_SETTINGS };
    return JSON.parse(raw) as Settings;
  }

  async save(settings: Settings): Promise<void> {
    localStorage.setItem(KEY, JSON.stringify(settings));
  }
}
