require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'バリデーション' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:icon) }
    it { is_expected.to validate_presence_of(:tile) }
  end

  describe 'アソシエーション' do
    it { is_expected.to have_many(:members).dependent(:destroy) }
    it { is_expected.to have_many(:expenses).dependent(:destroy) }
    it { is_expected.to have_many(:settlements).dependent(:destroy) }
  end

  it '作成時に invite_code を自動採番する' do
    group = create(:group)
    expect(group.invite_code).to be_present
  end

  describe '#open_expenses' do
    let(:group) { create(:group) }
    let(:member) { create(:member, group: group) }

    it '精算済み(settlement付き)の費用を除外する' do
      open = create(:expense, group: group, payer: member)
      settled = create(:expense, group: group, payer: member, settlement: create(:settlement, group: group))

      expect(group.open_expenses).to include(open)
      expect(group.open_expenses).not_to include(settled)
    end
  end

  describe '#member_for' do
    let(:group) { create(:group) }
    let(:user)  { create(:user) }

    it 'user に紐づくメンバーを返す' do
      member = create(:member, group: group, user: user)
      create(:member, group: group)
      expect(group.member_for(user)).to eq(member)
    end
  end
end
