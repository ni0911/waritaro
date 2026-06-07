module Api
  module V1
    # SheetItem の JSON 表現（ADR 0012 / alba）。
    class SheetItemSerializer
      include Alba::Resource

      root_key :sheet_item, :sheet_items

      attributes :id, :name, :amount, :burden_a, :burden_b, :card_id, :is_from_template
    end
  end
end
