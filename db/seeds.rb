# == Settings ==
setting = Setting.find_or_create_by!({}) do |s|
  s.member_a = "たろう"
  s.member_b = "はなこ"
end
puts "Setting: #{setting.member_a} / #{setting.member_b}"

# == Cards ==
card_a = Card.find_or_create_by!(name: "楽天カード") { |c| c.owner = "A" }
card_b = Card.find_or_create_by!(name: "イオンカード") { |c| c.owner = "B" }
puts "Cards: #{Card.count}件"

# == Template Items ==
[
  { name: "家賃",   amount: 120_000, burden_a: 80_000, burden_b: 40_000, card_id: nil,       sort_order: 1 },
  { name: "食費",   amount: 50_000,  burden_a: 25_000, burden_b: 25_000, card_id: card_b.id, sort_order: 2 },
  { name: "光熱費", amount: 15_000,  burden_a: 7_500,  burden_b: 7_500,  card_id: card_a.id, sort_order: 3 }
].each do |attrs|
  TemplateItem.find_or_create_by!(name: attrs[:name]) do |t|
    t.assign_attributes(attrs)
  end
end
puts "TemplateItems: #{TemplateItem.count}件"

# == Sample Sheet (今月) ==
sheet = Sheet.find_or_create_by!(year_month: "2026-03")

[
  { name: "家賃",         amount: 120_000, burden_a: 80_000, burden_b: 40_000, card_id: nil,       is_from_template: true  },
  { name: "食費",         amount: 48_000,  burden_a: 24_000, burden_b: 24_000, card_id: card_b.id, is_from_template: true  },
  { name: "光熱費",       amount: 14_500,  burden_a: 7_250,  burden_b: 7_250,  card_id: card_a.id, is_from_template: true  },
  { name: "たろうの本代", amount: 3_000,   burden_a: 0,      burden_b: 0,      card_id: nil,       is_from_template: false }
].each do |attrs|
  sheet.sheet_items.find_or_create_by!(name: attrs[:name]) do |i|
    i.assign_attributes(attrs)
  end
end
puts "SheetItems: #{sheet.sheet_items.count}件"

# == 精算確認 ==
result = SettlementService.new(sheet).calculate
puts "\n=== 2026-03 精算 ==="
puts "deposit_a: #{result.deposit_a}円"
puts "deposit_b: #{result.deposit_b}円"
puts "合計: #{result.total_shared_amount}円"
