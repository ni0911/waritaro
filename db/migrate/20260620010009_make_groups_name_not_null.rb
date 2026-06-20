class MakeGroupsNameNotNull < ActiveRecord::Migration[8.0]
  # groups.name は generalize で nullable 追加 → migrate_legacy_data で全行補完済み。
  # モデルは presence 検証しているが DB 制約がなかったため整合させる。
  # 本番安全マイグレーションの原則どおり、NOT NULL 化の前に NULL 残存を明示的に検証する。
  def up
    null_count = select_value("SELECT COUNT(*) FROM groups WHERE name IS NULL OR name = ''").to_i
    raise "groups.name に空の行が残存（#{null_count}件）。NOT NULL 化を中断します。" if null_count.positive?

    change_column_null :groups, :name, false
  end

  def down
    change_column_null :groups, :name, true
  end
end
