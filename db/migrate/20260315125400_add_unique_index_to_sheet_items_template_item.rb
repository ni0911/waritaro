class AddUniqueIndexToSheetItemsTemplateItem < ActiveRecord::Migration[8.0]
  def up
    # 既存の重複レコードを削除してから一意インデックスを付与する
    # 同じ (sheet_id, template_item_id) が複数ある場合、最小 id のみ残す
    execute(<<~SQL)
      DELETE FROM sheet_items
      WHERE template_item_id IS NOT NULL
        AND id NOT IN (
          SELECT MIN(id)
          FROM sheet_items
          WHERE template_item_id IS NOT NULL
          GROUP BY sheet_id, template_item_id
        )
    SQL

    add_index :sheet_items, [ :sheet_id, :template_item_id ],
              unique: true,
              where: "template_item_id IS NOT NULL",
              name: "index_sheet_items_on_sheet_id_and_template_item_id"
  end

  def down
    remove_index :sheet_items, name: "index_sheet_items_on_sheet_id_and_template_item_id"
  end
end
