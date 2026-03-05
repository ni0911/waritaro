class RemovePayerFromSheetItemsAndTemplateItems < ActiveRecord::Migration[8.0]
  def change
    remove_column :sheet_items, :payer, :string
    remove_column :template_items, :payer, :string
  end
end
