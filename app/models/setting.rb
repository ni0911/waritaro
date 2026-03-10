class Setting < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: :owner_id, optional: true
  has_many :users
  has_many :cards, dependent: :destroy
  has_many :sheets, dependent: :destroy
  has_many :template_items, dependent: :destroy

  validates :member_a, presence: true
  validates :member_b, presence: true
  validates :invite_code, uniqueness: true, allow_nil: true

  before_create :generate_invite_code

  private

  def generate_invite_code
    self.invite_code ||= SecureRandom.hex(8)
  end
end
