class CreateTemplateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :template_items do |t|
      t.string  :name,       null: false
      t.integer :amount,     null: false, default: 0
      t.string  :payer,      null: false
      t.integer :burden_a,   null: false, default: 0
      t.integer :burden_b,   null: false, default: 0
      t.references :card,    null: true,  foreign_key: true
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
  end
end
