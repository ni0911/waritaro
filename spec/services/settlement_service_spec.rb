require 'rails_helper'

RSpec.describe SettlementService do
  let(:sheet) { instance_double('Sheet') }

  def make_item(payer:, amount:, burden_a:, burden_b:)
    instance_double('SheetItem',
      payer: payer,
      amount: amount,
      burden_a: burden_a,
      burden_b: burden_b
    )
  end

  describe '#calculate' do
    context '通常ケース: A と B それぞれ負担あり' do
      before do
        items = [
          make_item(payer: 'A', amount: 80000, burden_a: 60000, burden_b: 20000), # 家賃
          make_item(payer: 'B', amount: 30000, burden_a: 15000, burden_b: 15000), # 食費
          make_item(payer: 'A', amount: 5000,  burden_a: 0,     burden_b: 0)     # 私物
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it 'total_shared_amount は私物を除いた合計' do
        result = described_class.new(sheet).calculate
        expect(result.total_shared_amount).to eq(110000) # 80000 + 30000
      end

      it 'burden_a の合計が正しい' do
        result = described_class.new(sheet).calculate
        expect(result.burden_a).to eq(75000) # 60000 + 15000
      end

      it 'burden_b の合計が正しい' do
        result = described_class.new(sheet).calculate
        expect(result.burden_b).to eq(35000) # 20000 + 15000
      end

      it 'paid_a は精算対象のうち A 払い分' do
        result = described_class.new(sheet).calculate
        expect(result.paid_a).to eq(80000)
      end

      it 'paid_b は精算対象のうち B 払い分' do
        result = described_class.new(sheet).calculate
        expect(result.paid_b).to eq(30000)
      end

      it 'transfer_a = burden_a - paid_a' do
        result = described_class.new(sheet).calculate
        # 75000 - 80000 = -5000 (払い過ぎ → 共有口座から受け取り)
        expect(result.transfer_a).to eq(-5000)
      end

      it 'transfer_b = burden_b - paid_b' do
        result = described_class.new(sheet).calculate
        # 35000 - 30000 = 5000 (B が共有口座に支払う)
        expect(result.transfer_b).to eq(5000)
      end

      it 'transfer_a + transfer_b = 0 (恒等式)' do
        result = described_class.new(sheet).calculate
        expect(result.transfer_a + result.transfer_b).to eq(0)
      end
    end

    context '全て割り勘（50:50）' do
      before do
        items = [
          make_item(payer: 'A', amount: 20000, burden_a: 10000, burden_b: 10000),
          make_item(payer: 'B', amount: 20000, burden_a: 10000, burden_b: 10000)
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it '両者が均等に払った場合 transfer は両方 0' do
        result = described_class.new(sheet).calculate
        expect(result.transfer_a).to eq(0)
        expect(result.transfer_b).to eq(0)
      end
    end

    context '精算対象アイテムがない' do
      before do
        allow(sheet).to receive(:sheet_items).and_return([])
      end

      it '全て 0 になる' do
        result = described_class.new(sheet).calculate
        expect(result.transfer_a).to eq(0)
        expect(result.transfer_b).to eq(0)
        expect(result.total_shared_amount).to eq(0)
      end
    end

    context '端数が発生するケース' do
      before do
        items = [
          make_item(payer: 'A', amount: 10001, burden_a: 5001, burden_b: 5000)
        ]
        allow(sheet).to receive(:sheet_items).and_return(items)
      end

      it '端数は burden_a 側が多く持つ' do
        result = described_class.new(sheet).calculate
        expect(result.burden_a + result.burden_b).to eq(10001)
        expect(result.transfer_a).to eq(5001 - 10001) # -5000
        expect(result.transfer_b).to eq(5000)
      end
    end
  end
end
