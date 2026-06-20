FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "ユーザー#{n}" }
    password { "password" }
  end
end
