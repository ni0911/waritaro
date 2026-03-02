require 'rails_helper'

RSpec.describe SheetItem, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:payer).in_array(%w[A B]) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_a).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_b).is_greater_than_or_equal_to(0) }
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:sheet) }
    it { is_expected.to belong_to(:card).optional }
    it { is_expected.to belong_to(:template_item).optional }
  end

  describe '#shared?' do
    it 'burden_a + burden_b > 0 のとき true' do
      item = build(:sheet_item, burden_a: 1000, burden_b: 0)
      expect(item.shared?).to be true
    end

    it 'burden_a == 0 && burden_b == 0 のとき false（私物）' do
      item = build(:sheet_item, burden_a: 0, burden_b: 0)
      expect(item.shared?).to be false
    end
  end
end
