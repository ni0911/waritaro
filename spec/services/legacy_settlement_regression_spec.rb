require 'rails_helper'

# 後方互換の回帰テスト（ADR 0013）。
# 旧 SettlementService は「各自が共同口座へ入れる入金額」を deposit_a/deposit_b として算出していた。
# 新モデルでは payer=共同口座 として表現するため、最小送金プランが
#   A → 共同口座 ¥Σburden_a / B → 共同口座 ¥Σburden_b
# となり、旧 deposit と一致しなければならない。
RSpec.describe "旧2人月次精算の後方互換", type: :model do
  let(:group)   { create(:group, kind: "couple") }
  let(:michima) { create(:member, group: group, name: "みちま", sort_order: 0) }
  let(:yuchima) { create(:member, group: group, name: "ゆちま", sort_order: 1) }
  let(:account) { create(:member, group: group, name: "共同口座", sort_order: 2) }

  # 旧 SheetItem(burden_a, burden_b) を共同口座払いの Expense へ変換する
  def add_legacy_item(name, burden_a, burden_b)
    amount = burden_a + burden_b
    return if amount.zero? # 私物(0/0)は精算対象外

    shares = []
    shares << { member: michima, amount: burden_a } if burden_a.positive?
    shares << { member: yuchima, amount: burden_b } if burden_b.positive?
    create(:expense, group: group, payer: account, title: name, amount: amount, shares: shares)
  end

  it '旧 deposit_a / deposit_b が最小送金プランとして再現される' do
    add_legacy_item("家賃", 60000, 20000)
    add_legacy_item("食費", 15000, 15000)
    add_legacy_item("私物", 0, 0) # 対象外

    plan = SettlementService.new(group).plan
    result = plan.transfers.map { |t| [ t.from.name, t.to.name, t.amount ] }

    # 旧: deposit_a = 75000, deposit_b = 35000
    expect(result).to contain_exactly(
      [ "みちま", "共同口座", 75000 ],
      [ "ゆちま", "共同口座", 35000 ]
    )
  end

  it '端数は burden_a 側が多く持つ（旧仕様どおり、share へそのまま反映）' do
    add_legacy_item("折半", 5001, 5000)

    plan = SettlementService.new(group).plan
    by_member = plan.nets.transform_keys(&:name)
    expect(by_member["みちま"]).to eq(-5001)
    expect(by_member["ゆちま"]).to eq(-5000)
    expect(by_member["共同口座"]).to eq(10001)
  end
end
