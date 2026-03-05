require 'rails_helper'

RSpec.describe SettlementService do
  let(:sheet) { instance_double('Sheet') }

  def make_item(amount:, burden_a:, burden_b:)
    instance_double('SheetItem',
      amount: amount,
      burden_a: burden_a,
      burden_b: burden_b
    )
  end

  describe '#calculate' do
    context '通常ケース: A と B それぞれ負担あり' do
      before do
        items = [
          make_item(amount: 80000, burden_a: 60000, burden_b: 20000), # 家賃
          make_item(amount: 30000, burden_a: 15000, burden_b: 15000), # 食費
          make_item(amount: 5000,  burden_a: 0,     burden_b: 0)     # 私物
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it 'total_shared_amount は私物を除いた burden 合計' do
        result = described_class.new(sheet).calculate
        expect(result.total_shared_amount).to eq(110000) # 75000 + 35000
      end

      it 'deposit_a の合計が正しい' do
        result = described_class.new(sheet).calculate
        expect(result.deposit_a).to eq(75000) # 60000 + 15000
      end

      it 'deposit_b の合計が正しい' do
        result = described_class.new(sheet).calculate
        expect(result.deposit_b).to eq(35000) # 20000 + 15000
      end
    end

    context '全て割り勘（50:50）' do
      before do
        items = [
          make_item(amount: 20000, burden_a: 10000, burden_b: 10000),
          make_item(amount: 20000, burden_a: 10000, burden_b: 10000)
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it 'deposit_a と deposit_b が等しい' do
        result = described_class.new(sheet).calculate
        expect(result.deposit_a).to eq(20000)
        expect(result.deposit_b).to eq(20000)
      end
    end

    context '精算対象アイテムがない' do
      before do
        allow(sheet).to receive(:sheet_items).and_return([])
      end

      it '全て 0 になる' do
        result = described_class.new(sheet).calculate
        expect(result.deposit_a).to eq(0)
        expect(result.deposit_b).to eq(0)
        expect(result.total_shared_amount).to eq(0)
      end
    end

    context '端数が発生するケース' do
      before do
        items = [
          make_item(amount: 10001, burden_a: 5001, burden_b: 5000)
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it '端数は burden_a 側が多く持つ' do
        result = described_class.new(sheet).calculate
        expect(result.deposit_a + result.deposit_b).to eq(10001)
        expect(result.deposit_a).to eq(5001)
        expect(result.deposit_b).to eq(5000)
      end
    end
  end
end
