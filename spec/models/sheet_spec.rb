require 'rails_helper'

RSpec.describe Sheet, type: :model do
  describe 'バリデーション' do
    subject { build(:sheet) }

    it { is_expected.to validate_presence_of(:year_month) }
    it { is_expected.to validate_uniqueness_of(:year_month).ignoring_case_sensitivity }

    it 'YYYY-MM形式を受け付ける' do
      sheet = build(:sheet, year_month: '2026-03')
      expect(sheet).to be_valid
    end

    it 'YYYY-MM以外の形式を拒否する' do
      sheet = build(:sheet, year_month: '2026/03')
      expect(sheet).not_to be_valid
    end

    it '不正な月（13月）を拒否する' do
      sheet = build(:sheet, year_month: '2026-13')
      expect(sheet).not_to be_valid
    end
  end

  describe 'アソシエーション' do
    it { is_expected.to have_many(:sheet_items).dependent(:destroy) }
  end
end
