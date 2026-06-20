FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "グループ#{n}" }
    icon { "🏝️" }
    tile { "#E7D3C2" }
    kind { "general" }
  end
end
