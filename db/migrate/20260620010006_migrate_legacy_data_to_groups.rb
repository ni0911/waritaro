class MigrateLegacyDataToGroups < ActiveRecord::Migration[8.0]
  # 旧 Setting(2人固定) / Sheet(月次) / SheetItem(burden_a/b) を
  # 新ドメイン Group / Member / Expense / ExpenseShare / Settlement へ変換する。
  #
  # 本番安全マイグレーションの原則に従い、モデルクラスは一切使わず raw SQL のみ使用する。
  PALETTE = %w[#C8704F #7B9E87 #D9A05B #9A8FB8 #6F94AE #C77F94].freeze
  ACCOUNT_COLOR = "#B3A99B".freeze # 共同口座メンバー

  def up
    now = quote(Time.current)

    select_all("SELECT id, member_a, member_b, owner_id, name FROM groups").each do |g|
      gid = g["id"].to_i

      # 1. グループ名・種別を補完
      if g["name"].to_s.strip.empty?
        label = quote("#{g['member_a']}・#{g['member_b']}")
        execute("UPDATE groups SET name = #{label}, kind = 'couple' WHERE id = #{gid}")
      end

      # 2. メンバー作成（A=owner / B=他ユーザー / 共同口座）
      owner_id = g["owner_id"]
      other_user_id = select_value(
        "SELECT id FROM users WHERE setting_id = #{gid}#{owner_id ? " AND id <> #{owner_id.to_i}" : ''} ORDER BY id LIMIT 1"
      )

      insert_member(gid, owner_id, g["member_a"], PALETTE[0], 0, now)
      insert_member(gid, other_user_id, g["member_b"], PALETTE[1], 1, now)
      insert_member(gid, nil, "共同口座", ACCOUNT_COLOR, 2, now)

      member_a_id = member_id(gid, 0)
      member_b_id = member_id(gid, 1)
      account_id  = member_id(gid, 2)

      # 3. 各 Sheet(月) を独立した清算スナップショット(Settlement)へ変換
      select_all("SELECT id, year_month, created_at FROM sheets WHERE setting_id = #{gid} ORDER BY year_month").each do |sheet|
        sid = sheet["id"].to_i
        settled_at = quote(sheet["created_at"] || Time.current)
        date = quote("#{sheet['year_month']}-01")

        settlement_id = select_value(<<~SQL)
          INSERT INTO settlements (group_id, settled_at, note, created_at, updated_at)
          VALUES (#{gid}, #{settled_at}, #{quote(sheet['year_month'])}, #{now}, #{now})
          RETURNING id
        SQL

        select_all("SELECT id, name, burden_a, burden_b FROM sheet_items WHERE sheet_id = #{sid}").each do |item|
          ba = item["burden_a"].to_i
          bb = item["burden_b"].to_i
          amount = ba + bb
          next if amount <= 0 # 私物(0/0)は精算対象外だったため変換しない

          expense_id = select_value(<<~SQL)
            INSERT INTO expenses (group_id, payer_id, settlement_id, title, amount, expense_date, split_mode, created_at, updated_at)
            VALUES (#{gid}, #{account_id}, #{settlement_id}, #{quote(item['name'])}, #{amount}, #{date}, 'itemized', #{now}, #{now})
            RETURNING id
          SQL

          insert_share(expense_id, member_a_id, ba, now) if ba.positive?
          insert_share(expense_id, member_b_id, bb, now) if bb.positive?
        end
      end
    end
  end

  def down
    execute("DELETE FROM expense_shares")
    execute("DELETE FROM expenses")
    execute("DELETE FROM settlements")
    execute("DELETE FROM members")
  end

  private

  def insert_member(gid, user_id, name, color, sort_order, now)
    uid = user_id ? user_id.to_i : "NULL"
    execute(<<~SQL)
      INSERT INTO members (group_id, user_id, name, color, sort_order, created_at, updated_at)
      VALUES (#{gid}, #{uid}, #{quote(name)}, #{quote(color)}, #{sort_order}, #{now}, #{now})
    SQL
  end

  def member_id(gid, sort_order)
    select_value("SELECT id FROM members WHERE group_id = #{gid} AND sort_order = #{sort_order} LIMIT 1")
  end

  def insert_share(expense_id, member_id, amount, now)
    execute(<<~SQL)
      INSERT INTO expense_shares (expense_id, member_id, amount, created_at, updated_at)
      VALUES (#{expense_id}, #{member_id}, #{amount}, #{now}, #{now})
    SQL
  end
end
