FactoryBot.define do
  factory :settlement do
    group
    settled_at { Time.current }
  end
end
