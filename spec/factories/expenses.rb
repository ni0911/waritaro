FactoryBot.define do
  factory :expense do
    group
    payer { association :member, group: group }
    title { "費用" }
    amount { 1000 }
    expense_date { Date.current }
    split_mode { "equal" }

    transient do
      # [{ member:, amount: }, ...]。未指定なら payer が全額負担。
      shares { [] }
    end

    after(:build) do |expense, evaluator|
      attrs = evaluator.shares
      attrs = [ { member: expense.payer, amount: expense.amount } ] if attrs.empty?
      attrs.each do |a|
        expense.shares.build(member: a[:member], amount: a[:amount])
      end
    end
  end
end
