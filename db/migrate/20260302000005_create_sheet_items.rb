class CreateSheetItems < ActiveRecord::Migration[8.0]
  def change
    create_table :sheet_items do |t|
      t.string  :name,               null: false
      t.integer :amount,             null: false, default: 0
      t.string  :payer,              null: false
      t.integer :burden_a,           null: false, default: 0
      t.integer :burden_b,           null: false, default: 0
      t.references :card,            null: true,  foreign_key: true
      t.boolean :is_from_template,   null: false, default: false
      t.references :template_item,   null: true,  foreign_key: true
      t.references :sheet,           null: false, foreign_key: true
      t.timestamps
    end
  end
end
