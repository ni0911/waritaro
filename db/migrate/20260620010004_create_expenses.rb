class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :group, null: false, foreign_key: true
      t.references :payer, null: false, foreign_key: { to_table: :members }
      t.references :settlement, null: true, foreign_key: true
      t.string :title, null: false
      t.integer :amount, null: false, default: 0
      t.date :expense_date, null: false
      t.string :split_mode, null: false, default: "equal"

      t.timestamps
    end

    add_index :expenses, [ :group_id, :expense_date ]
  end
end
