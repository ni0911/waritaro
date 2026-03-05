FactoryBot.define do
  factory :sheet_item do
    sequence(:name) { |n| "費用#{n}" }
    amount { 5000 }
    burden_a { 2500 }
    burden_b { 2500 }
    is_from_template { false }
    card { nil }
    template_item { nil }
    sheet
  end
end
