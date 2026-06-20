# 開発用サンプルデータ（ADR 0013 / 新ドメイン）。
# あらゆる立替清算（N人）に対応したデモを再現する。
require "securerandom"

demo = User.find_or_create_by!(email_address: "demo@example.com") do |u|
  u.name = "たろう"
  u.password = "password"
end
puts "User: #{demo.email_address} / password"

def member!(group, name, sort, user: nil)
  group.members.find_or_create_by!(name: name) do |m|
    m.color = Member::COLORS[sort % Member::COLORS.size]
    m.sort_order = sort
    m.user = user
  end
end

def expense!(group, title, payer, amount, participants, date)
  return if group.expenses.exists?(title: title)

  n = participants.size
  base = amount / n
  rem  = amount % n
  shares = participants.each_with_index.map { |m, i| { member: m, amount: base + (i < rem ? 1 : 0) } }
  group.expenses.create!(title: title, payer: payer, amount: amount, expense_date: date,
                         split_mode: "equal", shares_attributes: shares.map { |s| { member_id: s[:member].id, amount: s[:amount] } })
end

# == 沖縄旅行（5人・未精算）==
okinawa = Group.find_or_create_by!(name: "沖縄旅行") { |g| g.icon = "🏝️"; g.tile = "#E7D3C2"; g.owner = demo }
taro  = member!(okinawa, "たろう", 0, user: demo)
yui   = member!(okinawa, "ゆい", 1)
kenta = member!(okinawa, "けんた", 2)
mio   = member!(okinawa, "みお", 3)
sora  = member!(okinawa, "そら", 4)
expense!(okinawa, "ホテル 2泊", taro,  64_000, [ taro, yui, kenta, mio, sora ], Date.current - 12)
expense!(okinawa, "レンタカー", yui,   18_000, [ taro, yui, kenta, mio, sora ], Date.current - 3)
expense!(okinawa, "居酒屋",     kenta, 14_800, [ taro, yui, kenta, mio, sora ], Date.current - 3)
puts "沖縄旅行: #{okinawa.expenses.count}件 / #{SettlementService.new(okinawa).plan.transfers.size}回の送金"

# == ランチ部（3人）==
lunch = Group.find_or_create_by!(name: "ランチ部") { |g| g.icon = "🍱"; g.tile = "#EAD9B8"; g.owner = demo }
lt = member!(lunch, "たろう", 0, user: demo)
ly = member!(lunch, "ゆい", 1)
lm = member!(lunch, "みお", 2)
expense!(lunch, "定食 ×3", lt, 3_600, [ lt, ly, lm ], Date.current)
puts "ランチ部: #{lunch.expenses.count}件"

# == 金曜の飲み会（精算済み）==
nomikai = Group.find_or_create_by!(name: "金曜の飲み会") { |g| g.icon = "🍻"; g.tile = "#EAD9B8"; g.owner = demo }
nt = member!(nomikai, "たろう", 0, user: demo)
ns = member!(nomikai, "そら", 1)
if nomikai.expenses.empty?
  expense!(nomikai, "2軒目 バー", ns, 12_400, [ nt, ns ], Date.current - 6)
  s = nomikai.settlements.create!(settled_at: Time.current)
  nomikai.open_expenses.update_all(settlement_id: s.id)
end
puts "金曜の飲み会: 精算済み(#{nomikai.settlements.count}件のスナップショット)"

puts "\n=== 完了。demo@example.com / password でログイン ==="
