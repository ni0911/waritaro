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

    describe 'card のテナント整合性' do
      let(:setting) { create(:setting) }
      let(:sheet)   { create(:sheet, setting: setting) }

      it '同じグループの card なら有効' do
        card = create(:card, setting: setting)
        item = build(:sheet_item, sheet: sheet, card: card)
        expect(item).to be_valid
      end

      it '別グループの card は無効' do
        other_card = create(:card, setting: create(:setting))
        item = build(:sheet_item, sheet: sheet, card: other_card)
        expect(item).not_to be_valid
        expect(item.errors[:card]).to be_present
      end

      it 'card 未指定なら有効' do
        item = build(:sheet_item, sheet: sheet, card: nil)
        expect(item).to be_valid
      end
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to belong_to(:sheet) }
    it { is_expected.to belong_to(:card).optional }
    it { is_expected.to belong_to(:template_item).optional }
  end
end
