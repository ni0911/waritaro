class AddSettingIdToAppTables < ActiveRecord::Migration[8.0]
  def up
    # Step 1: nullable で追加
    add_reference :cards,          :setting, null: true, foreign_key: false
    add_reference :sheets,         :setting, null: true, foreign_key: false
    add_reference :template_items, :setting, null: true, foreign_key: false

    # Step 2: Setting を確実に確保（モデルではなく raw SQL を使用）
    # 理由: マイグレーション内で ActiveRecord モデルを使うと before_create コールバックや
    # スキーマキャッシュが不安定になるため、raw SQL が唯一安全な方法。
    result = execute("SELECT id FROM settings ORDER BY id LIMIT 1")
    setting_id = result.first&.dig("id")

    if setting_id.nil?
      # Setting が1件もない場合はデフォルト行を作成
      execute(<<~SQL)
        INSERT INTO settings (member_a, member_b, created_at, updated_at)
        VALUES ('たろう', 'はなこ', NOW(), NOW())
      SQL
      result = execute("SELECT id FROM settings ORDER BY id LIMIT 1")
      setting_id = result.first&.dig("id")
    end

    raise "Setting の取得/作成に失敗しました。" if setting_id.nil?

    # Step 3: 全既存行に setting_id をセット（if ガードなし、常に実行）
    execute("UPDATE cards          SET setting_id = #{setting_id} WHERE setting_id IS NULL")
    execute("UPDATE sheets         SET setting_id = #{setting_id} WHERE setting_id IS NULL")
    execute("UPDATE template_items SET setting_id = #{setting_id} WHERE setting_id IS NULL")

    # Step 4: NULL 残存チェック（change_column_null の前に明示的に検証）
    %w[cards sheets template_items].each do |table|
      count = execute("SELECT COUNT(*) AS c FROM #{table} WHERE setting_id IS NULL")
                .first["c"].to_i
      raise "#{table} に setting_id IS NULL のレコードが #{count} 件残っています。" if count > 0
    end

    # Step 5: NOT NULL 制約、FK 制約を追加
    change_column_null :cards,          :setting_id, false
    change_column_null :sheets,         :setting_id, false
    change_column_null :template_items, :setting_id, false

    add_foreign_key :cards,          :settings
    add_foreign_key :sheets,         :settings
    add_foreign_key :template_items, :settings

    # Step 6: year_month の unique index を setting_id スコープに変更
    remove_index :sheets, :year_month
    add_index :sheets, [ :year_month, :setting_id ], unique: true
  end

  def down
    remove_foreign_key :cards,          :settings
    remove_foreign_key :sheets,         :settings
    remove_foreign_key :template_items, :settings

    remove_index  :sheets, [ :year_month, :setting_id ]
    add_index     :sheets, :year_month, unique: true

    remove_reference :cards,          :setting
    remove_reference :sheets,         :setting
    remove_reference :template_items, :setting
  end
end
