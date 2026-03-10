class TemplateItem < ApplicationRecord
  belongs_to :setting
  belongs_to :card, optional: true
  has_many :sheet_items, dependent: :nullify

  validates :name, presence: true
  validates :amount,   numericality: { greater_than_or_equal_to: 0 }
  validates :burden_a, numericality: { greater_than_or_equal_to: 0 }
  validates :burden_b, numericality: { greater_than_or_equal_to: 0 }
  validate  :burden_sum_positive

  default_scope { order(:sort_order) }

  private

  def burden_sum_positive
    errors.add(:base, "負担額の合計は 1 円以上にしてください") if burden_a.to_i + burden_b.to_i <= 0
  end
end
