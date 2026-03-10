FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "カード#{n}" }
    owner { "A" }
    association :setting
  end
end
