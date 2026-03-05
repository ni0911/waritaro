require 'rails_helper'

RSpec.describe TemplateItem, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_a).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_b).is_greater_than_or_equal_to(0) }
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:card).optional }
  end

  describe '#split_mode' do
    context '割り勘（burden_a == burden_b == amount / 2）' do
      it 'amountが偶数のとき50:50になる' do
        item = build(:template_item, amount: 10000, burden_a: 5000, burden_b: 5000)
        expect(item.burden_a + item.burden_b).to eq(item.amount)
      end
    end

    context '私物（burden_a == 0 && burden_b == 0）' do
      it 'shared?がfalseになる' do
        item = build(:template_item, burden_a: 0, burden_b: 0)
        expect(item.shared?).to be false
      end
    end

    context '精算対象（burden_a + burden_b > 0）' do
      it 'shared?がtrueになる' do
        item = build(:template_item, burden_a: 3000, burden_b: 7000)
        expect(item.shared?).to be true
      end
    end
  end
end
