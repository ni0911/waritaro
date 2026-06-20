class CreateExpenseShares < ActiveRecord::Migration[8.0]
  def change
    create_table :expense_shares do |t|
      t.references :expense, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.integer :amount, null: false, default: 0

      t.timestamps
    end

    add_index :expense_shares, [ :expense_id, :member_id ], unique: true
  end
end
