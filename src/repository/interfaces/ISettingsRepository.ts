import type { Settings } from "../../types";

export interface ISettingsRepository {
  get(): Promise<Settings>;
  save(settings: Settings): Promise<void>;
}
