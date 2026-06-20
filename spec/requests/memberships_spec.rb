require 'rails_helper'

RSpec.describe "Memberships", type: :request do
  let(:user) { create(:user, name: "ゆい") }
  before { sign_in(user) }

  describe "POST /membership" do
    it "招待コードで空きメンバーを claim する" do
      group = create(:group)
      create(:member, group: group, name: "たろう", user: create(:user), sort_order: 0)
      empty = create(:member, group: group, name: "ゆい", user: nil, sort_order: 1)

      post membership_path, params: { invite_code: group.invite_code }

      expect(empty.reload.user).to eq(user)
      expect(response).to redirect_to(group_path(group))
    end

    it "空きメンバーがなければ新規メンバーを作成する" do
      group = create(:group)
      create(:member, group: group, name: "たろう", user: create(:user), sort_order: 0)

      expect {
        post membership_path, params: { invite_code: group.invite_code }
      }.to change { group.members.count }.by(1)
      expect(group.member_for(user)).to be_present
    end

    it "共同口座メンバーは claim 対象にしない" do
      group = create(:group)
      create(:member, group: group, name: "共同口座", user: nil, sort_order: 2)

      expect {
        post membership_path, params: { invite_code: group.invite_code }
      }.to change { group.members.count }.by(1)
      expect(group.members.find_by(name: "共同口座").user).to be_nil
    end

    it "不正なコードは 422" do
      post membership_path, params: { invite_code: "nope" }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
