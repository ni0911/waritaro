require 'rails_helper'

RSpec.describe "Groups", type: :request do
  let(:user) { create(:user, name: "たろう") }
  before { sign_in(user) }

  describe "POST /groups" do
    it "グループとメンバーを作成し、作成者を最初のメンバーに紐付ける" do
      expect {
        post groups_path, params: { group: { name: "沖縄旅行", icon: "🏝️", tile: "#E7D3C2" }, members: [ "たろう", "ゆい", "" ] }
      }.to change(Group, :count).by(1)

      group = Group.last
      expect(group.name).to eq("沖縄旅行")
      expect(group.members.map(&:name)).to eq(%w[たろう ゆい])
      expect(group.member_for(user)).to eq(group.members.find_by(name: "たろう"))
      expect(response).to redirect_to(group_path(group, fresh: 1))
    end

    it "名前が空なら 422" do
      post groups_path, params: { group: { name: "", icon: "🏝️", tile: "#E7D3C2" }, members: [ "たろう" ] }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /groups/:id" do
    let(:group) { create(:group) }
    let!(:me) { create(:member, group: group, user: user, sort_order: 0) }
    let!(:other) { create(:member, group: group, sort_order: 1) }

    it "精算プランを表示する" do
      create(:expense, group: group, payer: me, amount: 2000,
        shares: [ { member: me, amount: 1000 }, { member: other, amount: 1000 } ])
      get group_path(group)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("精算プラン")
    end

    it "参加していないグループにはアクセスできない" do
      stranger = create(:group)
      create(:member, group: stranger)
      get group_path(stranger)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /groups/:id/invite & /share" do
    let(:group) { create(:group) }
    let!(:me) { create(:member, group: group, user: user) }

    it "招待ページに招待コードを表示" do
      get invite_group_path(group)
      expect(response.body).to include(group.invite_code)
    end

    it "共有ページに LINE テキストを表示" do
      get share_group_path(group)
      expect(response).to have_http_status(:ok)
    end
  end
end
