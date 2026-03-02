class Card < ApplicationRecord
  OWNERS = %w[A B].freeze

  has_many :template_items, dependent: :nullify
  has_many :sheet_items, dependent: :nullify

  validates :name, presence: true
  validates :owner, inclusion: { in: OWNERS }
end
