require 'rails_helper'

RSpec.describe "Settlements", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let!(:me)  { create(:member, group: group, user: user, sort_order: 0) }
  let!(:yui) { create(:member, group: group, sort_order: 1) }

  before { sign_in(user) }

  it "未精算費用をスナップショット化して精算済みにする" do
    create(:expense, group: group, payer: me, amount: 2000,
      shares: [ { member: me, amount: 1000 }, { member: yui, amount: 1000 } ])

    expect {
      post group_settlement_path(group)
    }.to change(Settlement, :count).by(1)

    expect(group.open_expenses).to be_empty
    expect(SettlementService.new(group).plan.transfers).to be_empty
    expect(response).to redirect_to(group_path(group))
  end

  it "記録がなければ精算できない" do
    post group_settlement_path(group)
    expect(Settlement.count).to eq(0)
    expect(response).to redirect_to(group_path(group))
  end
end
