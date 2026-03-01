import { useState, useEffect, useCallback } from "react";
import type { TemplateItem } from "../types";
import { templateRepository } from "../repository";

export function useTemplates() {
  const [templates, setTemplates] = useState<TemplateItem[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    setTemplates(await templateRepository.findAll());
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const saveTemplate = useCallback(async (item: TemplateItem) => {
    await templateRepository.save(item);
    await load();
  }, [load]);

  const deleteTemplate = useCallback(async (id: string) => {
    await templateRepository.delete(id);
    await load();
  }, [load]);

  const updateOrder = useCallback(async (items: TemplateItem[]) => {
    await templateRepository.updateOrder(items);
    await load();
  }, [load]);

  return { templates, loading, saveTemplate, deleteTemplate, updateOrder, reload: load };
}
