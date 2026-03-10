FactoryBot.define do
  factory :sheet do
    sequence(:year_month) { |n| "2026-%02d" % ((n % 12) + 1) }
    association :setting
  end
end
