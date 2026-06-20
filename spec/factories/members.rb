FactoryBot.define do
  factory :member do
    group
    sequence(:name) { |n| "メンバー#{n}" }
    color { "#C8704F" }
    sort_order { 0 }
  end
end
