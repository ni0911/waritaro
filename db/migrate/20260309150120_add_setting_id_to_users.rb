class AddSettingIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :setting, null: true, foreign_key: true
  end
end
