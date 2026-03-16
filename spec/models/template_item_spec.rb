require 'rails_helper'

RSpec.describe TemplateItem, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_a).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_b).is_greater_than_or_equal_to(0) }

    it 'burden_a + burden_b が 0 のとき無効' do
      item = build(:template_item, burden_a: 0, burden_b: 0)
      expect(item).not_to be_valid
      expect(item.errors[:base]).to be_present
    end

    it 'burden_b だけ > 0 のとき有効' do
      item = build(:template_item, amount: 5000, burden_a: 0, burden_b: 5000)
      expect(item).to be_valid
    end

    it 'burden_a + burden_b が amount と一致しないとき無効' do
      item = build(:template_item, amount: 10000, burden_a: 3000, burden_b: 3000)
      expect(item).not_to be_valid
      expect(item.errors[:base]).to be_present
    end

    it 'burden_a + burden_b が amount と一致するとき有効' do
      item = build(:template_item, amount: 10000, burden_a: 3000, burden_b: 7000)
      expect(item).to be_valid
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:card).optional }
  end

  describe '割り勘モード' do
    it 'amount が偶数のとき 50:50 になる' do
      item = build(:template_item, amount: 10000, burden_a: 5000, burden_b: 5000)
      expect(item.burden_a + item.burden_b).to eq(item.amount)
    end
  end
end
