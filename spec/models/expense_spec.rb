require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:group) { create(:group) }
  let(:a) { create(:member, group: group, sort_order: 0) }
  let(:b) { create(:member, group: group, sort_order: 1) }

  describe 'バリデーション' do
    it '負担額の合計が金額と一致しないと無効' do
      expense = build(:expense, group: group, payer: a, amount: 1000,
        shares: [ { member: a, amount: 400 }, { member: b, amount: 400 } ])
      expect(expense).not_to be_valid
      expect(expense.errors[:base].join).to include("一致しません")
    end

    it '負担額の合計が金額と一致すれば有効' do
      expense = build(:expense, group: group, payer: a, amount: 1000,
        shares: [ { member: a, amount: 500 }, { member: b, amount: 500 } ])
      expect(expense).to be_valid
    end

    it '金額は正の整数でなければならない' do
      expect(build(:expense, group: group, payer: a, amount: 0)).not_to be_valid
    end

    it 'payer は同じグループのメンバーでなければならない' do
      other = create(:member, group: create(:group))
      expense = build(:expense, group: group, payer: other, amount: 100,
        shares: [ { member: a, amount: 100 } ])
      expect(expense).not_to be_valid
      expect(expense.errors[:payer]).to be_present
    end

    it 'split_mode は許可値のみ' do
      expect(build(:expense, group: group, payer: a, split_mode: "bogus")).not_to be_valid
    end
  end
end
