import type { Card } from "../../types";
import type { ICardRepository } from "../interfaces/ICardRepository";

const KEY = "waritaro:cards";

export class LocalStorageCardRepository implements ICardRepository {
  async findAll(): Promise<Card[]> {
    const raw = localStorage.getItem(KEY);
    if (!raw) return [];
    return JSON.parse(raw) as Card[];
  }

  async findById(id: string): Promise<Card | null> {
    const all = await this.findAll();
    return all.find((c) => c.id === id) ?? null;
  }

  async save(card: Card): Promise<void> {
    const all = await this.findAll();
    const index = all.findIndex((c) => c.id === card.id);
    if (index >= 0) {
      all[index] = card;
    } else {
      all.push(card);
    }
    localStorage.setItem(KEY, JSON.stringify(all));
  }

  async delete(id: string): Promise<void> {
    const all = await this.findAll();
    localStorage.setItem(KEY, JSON.stringify(all.filter((c) => c.id !== id)));
  }
}
