class DropLegacyTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :sheet_items
    drop_table :sheets
    drop_table :template_items
    drop_table :cards

    remove_column :groups, :member_a
    remove_column :groups, :member_b

    # users.setting_id は所属を Member 経由に移行したため不要。
    # データ移行で参照済みなのでここで除去する。
    remove_reference :users, :setting, foreign_key: { to_table: :groups }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
