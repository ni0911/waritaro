require 'rails_helper'

RSpec.describe SettlementService do
  # nets を貪欲法で最小送金プランへ変換する純粋ロジックの検証
  describe '.minimize_transfers' do
    it '2者: 一方が立替、他方が負担 → 1回の送金' do
      transfers = described_class.minimize_transfers({ "a" => 1000, "b" => -1000 })
      expect(transfers).to contain_exactly({ from: "b", to: "a", amount: 1000 })
    end

    it '全員精算済み(net 0)なら送金なし' do
      expect(described_class.minimize_transfers({ "a" => 0, "b" => 0 })).to eq([])
    end

    it '3人: 1人が立替、2人が負担 → 2回' do
      transfers = described_class.minimize_transfers({ "me" => 1800, "yui" => -1000, "mio" => -800 })
      expect(transfers).to contain_exactly(
        { from: "yui", to: "me", amount: 1000 },
        { from: "mio", to: "me", amount: 800 }
      )
    end

    it 'n人の送金回数は高々 n-1 回（最小性）' do
      nets = { "a" => 5, "b" => 5, "c" => 5, "d" => -5, "e" => -5, "f" => -5 }
      transfers = described_class.minimize_transfers(nets)
      expect(transfers.size).to be <= nets.size - 1
    end

    it '送金の総額は債務の総額に一致し、各 net を相殺する' do
      nets = { "a" => 8400, "b" => -3000, "c" => -2400, "d" => -1500, "e" => -1500 }
      transfers = described_class.minimize_transfers(nets)
      # 各メンバーの (受取 - 支払) が net を打ち消す
      balance = Hash.new(0)
      transfers.each do |t|
        balance[t[:from]] -= t[:amount]
        balance[t[:to]]   += t[:amount]
      end
      nets.each { |id, n| expect(balance[id]).to eq(n) }
    end
  end

  describe '#plan（グループの未精算費用から算出）' do
    let(:group) { create(:group) }
    let(:taro) { create(:member, group: group, name: "たろう", sort_order: 0) }
    let(:yui)  { create(:member, group: group, name: "ゆい",   sort_order: 1) }
    let(:mio)  { create(:member, group: group, name: "みお",   sort_order: 2) }

    it '均等割: たろうが3000立替、3人で均等 → ゆい・みおがそれぞれ1000送金' do
      create(:expense, group: group, payer: taro, amount: 3000,
        shares: [ { member: taro, amount: 1000 }, { member: yui, amount: 1000 }, { member: mio, amount: 1000 } ])

      plan = described_class.new(group).plan
      expect(plan.transfers.map { |t| [ t.from.name, t.to.name, t.amount ] }).to contain_exactly(
        [ "ゆい", "たろう", 1000 ],
        [ "みお", "たろう", 1000 ]
      )
    end

    it '純収支(nets)の総和は常に0' do
      create(:expense, group: group, payer: taro, amount: 3000,
        shares: [ { member: taro, amount: 1000 }, { member: yui, amount: 1000 }, { member: mio, amount: 1000 } ])
      create(:expense, group: group, payer: yui, amount: 1200,
        shares: [ { member: yui, amount: 600 }, { member: mio, amount: 600 } ])

      plan = described_class.new(group).plan
      expect(plan.nets.values.sum).to eq(0)
    end

    it '精算済み(settlement付き)の費用は残高に含めない' do
      settlement = create(:settlement, group: group)
      create(:expense, group: group, payer: taro, amount: 3000, settlement: settlement,
        shares: [ { member: taro, amount: 1000 }, { member: yui, amount: 1000 }, { member: mio, amount: 1000 } ])

      plan = described_class.new(group).plan
      expect(plan.transfers).to be_empty
    end
  end
end
