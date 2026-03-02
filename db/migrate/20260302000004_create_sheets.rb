class CreateSheets < ActiveRecord::Migration[8.0]
  def change
    create_table :sheets do |t|
      t.string :year_month, null: false
      t.timestamps
    end
    add_index :sheets, :year_month, unique: true
  end
end
