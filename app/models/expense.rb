class Expense < ApplicationRecord
  SPLIT_MODES = %w[equal itemized ratio].freeze

  belongs_to :group
  belongs_to :payer, class_name: "Member"
  belongs_to :settlement, optional: true

  has_many :shares, class_name: "ExpenseShare", dependent: :destroy
  has_many :share_members, through: :shares, source: :member
  accepts_nested_attributes_for :shares, allow_destroy: true, reject_if: ->(a) { a[:member_id].blank? }

  validates :title, presence: true
  validates :amount, numericality: { only_integer: true, greater_than: 0 }
  validates :expense_date, presence: true
  validates :split_mode, inclusion: { in: SPLIT_MODES }
  validate :shares_sum_equals_amount
  validate :payer_belongs_to_group
  validate :shares_members_belong_to_group

  scope :open, -> { where(settlement_id: nil) }

  private

  def active_shares
    shares.reject(&:marked_for_destruction?)
  end

  def shares_sum_equals_amount
    return if active_shares.empty? # presence は別途 amount で担保
    return if active_shares.sum { |s| s.amount.to_i } == amount.to_i

    errors.add(:base, "負担額の合計（#{active_shares.sum { |s| s.amount.to_i }}）が金額（#{amount}）と一致しません")
  end

  def payer_belongs_to_group
    return if payer.nil? || group.nil?
    return if payer.group_id == group_id

    errors.add(:payer, "は同じグループのメンバーを指定してください")
  end

  def shares_members_belong_to_group
    return if group.nil?

    active_shares.each do |s|
      next if s.member.nil? || s.member.group_id == group_id

      errors.add(:base, "負担メンバーは同じグループのメンバーである必要があります")
      break
    end
  end
end
