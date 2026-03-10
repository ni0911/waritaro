class AddSettingIdToAppTables < ActiveRecord::Migration[8.0]
  def up
    # Step 1: nullable で追加（既存データが壊れない・FK 制約なし）
    add_reference :cards,          :setting, null: true, foreign_key: false
    add_reference :sheets,         :setting, null: true, foreign_key: false
    add_reference :template_items, :setting, null: true, foreign_key: false

    # Step 2: 既存行のデータ移行
    # Setting が存在する場合、全既存レコードを最初の Setting に割り当てる。
    # 本番環境での初回デプロイ時は認証導入前なのでデータなし（またはシングルテナント 1 行のみ）を前提とする。
    # データが存在する場合は別途移行スクリプトで対応すること（ADR 0010 参照）。
    if (default_setting = Setting.first)
      id = default_setting.id
      execute("UPDATE cards          SET setting_id = #{id} WHERE setting_id IS NULL")
      execute("UPDATE sheets         SET setting_id = #{id} WHERE setting_id IS NULL")
      execute("UPDATE template_items SET setting_id = #{id} WHERE setting_id IS NULL")
    end

    # Step 3: null: false を強制（全行が埋まっている前提）
    change_column_null :cards,          :setting_id, false
    change_column_null :sheets,         :setting_id, false
    change_column_null :template_items, :setting_id, false

    # Step 4: FK 制約を追加
    add_foreign_key :cards,          :settings
    add_foreign_key :sheets,         :settings
    add_foreign_key :template_items, :settings

    # Step 5: year_month の unique index を setting_id スコープに変更
    remove_index :sheets, :year_month
    add_index :sheets, [:year_month, :setting_id], unique: true
  end

  def down
    remove_foreign_key :cards,          :settings
    remove_foreign_key :sheets,         :settings
    remove_foreign_key :template_items, :settings

    remove_index  :sheets, [:year_month, :setting_id]
    add_index     :sheets, :year_month, unique: true

    remove_reference :cards,          :setting
    remove_reference :sheets,         :setting
    remove_reference :template_items, :setting
  end
end
