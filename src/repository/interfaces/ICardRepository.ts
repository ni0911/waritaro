import type { Card } from "../../types";

export interface ICardRepository {
  findAll(): Promise<Card[]>;
  findById(id: string): Promise<Card | null>;
  save(card: Card): Promise<void>;
  delete(id: string): Promise<void>;
}
