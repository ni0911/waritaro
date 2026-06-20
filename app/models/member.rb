class Member < ApplicationRecord
  # メンバーアバターのウォームパレット（design_handoff_waritaro）
  COLORS = %w[#C8704F #7B9E87 #D9A05B #9A8FB8 #6F94AE #C77F94 #8FA98C #B98AA0].freeze

  belongs_to :group
  belongs_to :user, optional: true

  has_many :paid_expenses, class_name: "Expense", foreign_key: :payer_id, dependent: :restrict_with_error
  has_many :expense_shares, dependent: :destroy

  validates :name, presence: true
  validates :color, presence: true
  validates :user_id, uniqueness: { scope: :group_id }, allow_nil: true

  def you?(user)
    user.present? && user_id == user.id
  end
end
