require 'rails_helper'

RSpec.describe "Expenses", type: :request do
  let(:user) { create(:user, name: "たろう") }
  let(:group) { create(:group) }
  let!(:me)  { create(:member, group: group, user: user, name: "たろう", sort_order: 0) }
  let!(:yui) { create(:member, group: group, name: "ゆい", sort_order: 1) }
  let!(:mio) { create(:member, group: group, name: "みお", sort_order: 2) }

  before { sign_in(user) }

  describe "GET new" do
    it "追加フォームを表示する" do
      get new_group_expense_path(group)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("立て替えた人")
    end
  end

  describe "POST create" do
    it "均等割りで費用を記録し、端数を含めて合計が一致する" do
      expect {
        post group_expenses_path(group), params: {
          amount: 1000, title: "ランチ", payer_id: me.id,
          participant_ids: [ me.id, yui.id, mio.id ], split_mode: "equal"
        }
      }.to change(Expense, :count).by(1)

      expense = Expense.last
      expect(expense.amount).to eq(1000)
      expect(expense.shares.sum(&:amount)).to eq(1000)
      expect(expense.shares.map(&:amount).sort).to eq([ 333, 333, 334 ])
      expect(response).to redirect_to(group_path(group))
    end

    it "金額指定(custom)では指定額をそのまま負担にする" do
      post group_expenses_path(group), params: {
        amount: 1000, title: "宿", payer_id: me.id,
        participant_ids: [ me.id, yui.id ], split_mode: "custom",
        shares: { me.id.to_s => 700, yui.id.to_s => 300 }
      }
      expense = Expense.last
      expect(expense.shares.find_by(member: me).amount).to eq(700)
      expect(expense.shares.find_by(member: yui).amount).to eq(300)
    end

    it "金額が0なら記録されない" do
      expect {
        post group_expenses_path(group), params: { amount: 0, title: "x", payer_id: me.id, participant_ids: [ me.id ] }
      }.not_to change(Expense, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE destroy" do
    it "記録を削除する" do
      expense = create(:expense, group: group, payer: me)
      expect {
        delete group_expense_path(group, expense)
      }.to change(Expense, :count).by(-1)
    end
  end
end
