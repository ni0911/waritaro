require 'rails_helper'

RSpec.describe "Home", type: :request do
  let(:user) { create(:user, name: "たろう") }
  let(:group) { create(:group, name: "沖縄旅行") }
  let!(:me) { create(:member, group: group, user: user, name: "たろう", sort_order: 0) }
  let!(:yui) { create(:member, group: group, name: "ゆい", sort_order: 1) }

  before { sign_in(user) }

  it "所属グループを一覧表示する" do
    create(:expense, group: group, payer: me, amount: 2000,
      shares: [ { member: me, amount: 1000 }, { member: yui, amount: 1000 } ])

    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("沖縄旅行")
    expect(response.body).to include("こんにちは").or include("おはよう").or include("こんばんは")
  end

  it "グループ未所属ユーザーはグループ作成へ誘導される" do
    other = create(:user)
    sign_in(other)
    get root_path
    expect(response).to redirect_to(new_group_path)
  end

  it "未ログインはログインへ" do
    delete session_path
    get root_path
    expect(response).to redirect_to(new_session_path)
  end
end
