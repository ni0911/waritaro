class Setting < ApplicationRecord
  validates :member_a, presence: true
  validates :member_b, presence: true

  def self.instance
    first || create!(member_a: "たろう", member_b: "はなこ")
  end
end
