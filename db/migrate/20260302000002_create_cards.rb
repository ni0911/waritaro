class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.string :name,  null: false
      t.string :owner, null: false
      t.timestamps
    end
  end
end
