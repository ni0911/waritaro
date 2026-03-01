import { useState, useEffect, useCallback } from "react";
import type { Card } from "../types";
import { cardRepository } from "../repository";

export function useCards() {
  const [cards, setCards] = useState<Card[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setCards(await cardRepository.findAll());
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const saveCard = useCallback(async (card: Card) => {
    await cardRepository.save(card);
    await load();
  }, [load]);

  const deleteCard = useCallback(async (id: string) => {
    await cardRepository.delete(id);
    await load();
  }, [load]);

  return { cards, loading, saveCard, deleteCard, reload: load };
}
