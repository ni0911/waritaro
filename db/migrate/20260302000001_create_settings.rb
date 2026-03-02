class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      t.string :member_a, null: false, default: "たろう"
      t.string :member_b, null: false, default: "はなこ"
      t.timestamps
    end
  end
end
