import type { TemplateItem } from "../../types";

export interface ITemplateRepository {
  findAll(): Promise<TemplateItem[]>;
  save(item: TemplateItem): Promise<void>;
  delete(id: string): Promise<void>;
  updateOrder(items: TemplateItem[]): Promise<void>;
}
