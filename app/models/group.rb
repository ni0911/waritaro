class Group < ApplicationRecord
  # グループタイルの淡色候補（北欧ウォーム / design_handoff_waritaro）
  TILES = %w[#E7D3C2 #D8E0D2 #EAD9B8 #D4DEE6 #E8D2D4 #DDD6E4 #E3DCC9 #CFDDD8].freeze

  belongs_to :owner, class_name: "User", foreign_key: :owner_id, optional: true
  has_many :members, -> { order(:sort_order, :id) }, dependent: :destroy
  has_many :users, through: :members
  has_many :expenses, dependent: :destroy
  has_many :expense_shares, through: :expenses
  has_many :settlements, dependent: :destroy

  validates :name, presence: true
  validates :icon, presence: true
  validates :tile, presence: true
  validates :invite_code, uniqueness: true, allow_nil: true

  before_create :generate_invite_code

  # 未精算（ライブ台帳）の費用。グループ残高はここから算出する。
  def open_expenses
    expenses.where(settlement_id: nil)
  end

  # current_user に紐づくこのグループのメンバー（= 「あなた」）
  def member_for(user)
    return nil unless user
    members.find { |m| m.user_id == user.id }
  end

  def settled?
    SettlementService.new(self).plan.transfers.empty?
  end

  private

  def generate_invite_code
    self.invite_code ||= SecureRandom.hex(8)
  end
end
