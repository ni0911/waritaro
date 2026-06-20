class CreateSettlements < ActiveRecord::Migration[8.0]
  def change
    create_table :settlements do |t|
      t.references :group, null: false, foreign_key: true
      t.datetime :settled_at, null: false
      t.string :note

      t.timestamps
    end
  end
end
