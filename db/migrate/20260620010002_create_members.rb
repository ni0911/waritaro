class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#C8704F"
      t.integer :sort_order, null: false, default: 0

      t.timestamps
    end

    # 1ユーザーは1グループ内に1メンバーまで（紐付けの一意性）
    add_index :members, [ :group_id, :user_id ], unique: true, where: "user_id IS NOT NULL"
  end
end
