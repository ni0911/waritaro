class TemplateItem < ApplicationRecord
  PAYERS = %w[A B].freeze

  belongs_to :card, optional: true

  validates :name, presence: true
  validates :payer, inclusion: { in: PAYERS }
  validates :amount,   numericality: { greater_than_or_equal_to: 0 }
  validates :burden_a, numericality: { greater_than_or_equal_to: 0 }
  validates :burden_b, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:sort_order) }

  def shared?
    burden_a + burden_b > 0
  end
end
