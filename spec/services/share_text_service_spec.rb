require 'rails_helper'

RSpec.describe ShareTextService do
  let(:group) { create(:group, name: "沖縄旅行", icon: "🏝️") }
  let(:taro) { create(:member, group: group, name: "たろう", sort_order: 0) }
  let(:yui)  { create(:member, group: group, name: "ゆい",   sort_order: 1) }
  let(:mio)  { create(:member, group: group, name: "みお",   sort_order: 2) }

  describe '#group_settlement' do
    it '最小送金プランを LINE 貼り付け用テキストにする' do
      create(:expense, group: group, payer: taro, amount: 3600,
        shares: [ { member: taro, amount: 1200 }, { member: yui, amount: 1200 }, { member: mio, amount: 1200 } ])

      text = described_class.new(group).group_settlement

      expect(text).to include("【沖縄旅行】🏝️ の精算")
      expect(text).to include("ゆい → たろう　¥1,200")
      expect(text).to include("みお → たろう　¥1,200")
      expect(text).to include("送金は 2 回でOK")
      expect(text).to include("waritaro")
    end

    it '精算済みなら完了メッセージ' do
      text = described_class.new(group).group_settlement
      expect(text).to include("🎉 精算は完了しています！")
      expect(text).not_to include("送金は")
    end
  end
end
