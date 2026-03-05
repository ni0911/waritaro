require 'rails_helper'

RSpec.describe SheetItem, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_a).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:burden_b).is_greater_than_or_equal_to(0) }

    it 'burden_a + burden_b が 0 のとき無効' do
      item = build(:sheet_item, burden_a: 0, burden_b: 0)
      expect(item).not_to be_valid
      expect(item.errors[:base]).to be_present
    end

    it 'burden_a だけ > 0 のとき有効' do
      item = build(:sheet_item, burden_a: 1000, burden_b: 0)
      expect(item).to be_valid
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:sheet) }
    it { is_expected.to belong_to(:card).optional }
    it { is_expected.to belong_to(:template_item).optional }
  end
end
