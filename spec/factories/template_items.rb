FactoryBot.define do
  factory :template_item do
    sequence(:name) { |n| "テンプレート#{n}" }
    amount { 10000 }
    payer { "A" }
    burden_a { 5000 }
    burden_b { 5000 }
    card { nil }
    sort_order { 0 }
  end
end
