import type { TemplateItem } from "../../types";
import type { ITemplateRepository } from "../interfaces/ITemplateRepository";

const KEY = "waritaro:templates";

export class LocalStorageTemplateRepository implements ITemplateRepository {
  async findAll(): Promise<TemplateItem[]> {
    const raw = localStorage.getItem(KEY);
    if (!raw) return [];
    const items = JSON.parse(raw) as TemplateItem[];
    return items.sort((a, b) => a.sortOrder - b.sortOrder);
  }

  async save(item: TemplateItem): Promise<void> {
    const all = await this.findAll();
    const index = all.findIndex((t) => t.id === item.id);
    if (index >= 0) {
      all[index] = item;
    } else {
      all.push(item);
    }
    localStorage.setItem(KEY, JSON.stringify(all));
  }

  async delete(id: string): Promise<void> {
    const all = await this.findAll();
    localStorage.setItem(KEY, JSON.stringify(all.filter((t) => t.id !== id)));
  }

  async updateOrder(items: TemplateItem[]): Promise<void> {
    localStorage.setItem(KEY, JSON.stringify(items));
  }
}
