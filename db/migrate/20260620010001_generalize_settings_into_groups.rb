class GeneralizeSettingsIntoGroups < ActiveRecord::Migration[8.0]
  def up
    rename_table :settings, :groups

    add_column :groups, :name, :string
    add_column :groups, :icon, :string, default: "🏠", null: false
    add_column :groups, :tile, :string, default: "#E7D3C2", null: false
    add_column :groups, :kind, :string, default: "general", null: false

    # member_a / member_b は後方互換データ移行（後続マイグレーション）で
    # Member レコードへ変換したのち drop する。ここではまだ残す。
  end

  def down
    remove_column :groups, :kind
    remove_column :groups, :tile
    remove_column :groups, :icon
    remove_column :groups, :name
    rename_table :groups, :settings
  end
end
