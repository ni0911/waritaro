class AddGroupFieldsToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :invite_code, :string
    add_column :settings, :owner_id, :bigint
    add_index :settings, :invite_code, unique: true
    add_foreign_key :settings, :users, column: :owner_id
  end
end
