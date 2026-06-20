require 'rails_helper'

RSpec.describe Member, type: :model do
  describe 'バリデーション' do
    subject { build(:member) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:color) }

    it '同一グループ内で user の重複を許さない' do
      group = create(:group)
      user = create(:user)
      create(:member, group: group, user: user)
      dup = build(:member, group: group, user: user)
      expect(dup).not_to be_valid
    end

    it '別グループであれば同じ user を紐付けられる' do
      user = create(:user)
      create(:member, group: create(:group), user: user)
      other = build(:member, group: create(:group), user: user)
      expect(other).to be_valid
    end
  end

  describe '#you?' do
    let(:user) { create(:user) }

    it 'user_id が一致すれば true' do
      member = create(:member, user: user)
      expect(member.you?(user)).to be true
    end

    it '紐付けなしなら false' do
      expect(create(:member).you?(user)).to be false
    end
  end
end
