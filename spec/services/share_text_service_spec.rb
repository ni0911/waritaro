require 'rails_helper'

RSpec.describe ShareTextService do
  let(:setting) { instance_double('Setting', member_a: 'たろう', member_b: 'はなこ') }
  let(:card_a)  { instance_double('Card', id: 1, name: '楽天カード') }
  let(:cards)   { [ card_a ] }

  def make_item(name:, amount:, payer:, burden_a:, burden_b:, card_id: nil)
    instance_double('SheetItem',
      name: name, amount: amount, payer: payer,
      burden_a: burden_a, burden_b: burden_b, card_id: card_id
    )
  end

  describe '#generate' do
    let(:items) do
      [
        make_item(name: '家賃', amount: 120000, payer: 'A', burden_a: 80000, burden_b: 40000),
        make_item(name: '食費', amount: 30000,  payer: 'B', burden_a: 15000, burden_b: 15000, card_id: 1),
        make_item(name: 'A私物', amount: 5000, payer: 'A', burden_a: 0, burden_b: 0)
      ]
    end

    let(:sheet) do
      instance_double('Sheet',
        year_month: '2026-03',
        sheet_items: items
      )
    end

    subject(:text) { described_class.new(sheet, setting, cards).generate }

    it 'ヘッダーに年月が含まれる' do
      expect(text).to include('2026年3月')
    end

    it '精算対象のアイテムが含まれる' do
      expect(text).to include('家賃')
      expect(text).to include('食費')
    end

    it '私物のアイテムが含まれる' do
      expect(text).to include('A私物')
    end

    it 'たろう（A）の振込額が含まれる' do
      expect(text).to include('たろう')
    end

    it 'はなこ（B）の振込額が含まれる' do
      expect(text).to include('はなこ')
    end

    it 'カード名が含まれる' do
      expect(text).to include('楽天カード')
    end

    it '精算（共有口座）の表記が含まれる' do
      expect(text).to include('共有口座')
    end
  end
end
