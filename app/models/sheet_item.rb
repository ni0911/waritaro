class SheetItem < ApplicationRecord
  belongs_to :sheet
  belongs_to :card, optional: true
  belongs_to :template_item, optional: true

  validates :name, presence: true
  validates :amount,   numericality: { greater_than_or_equal_to: 0 }
  validates :burden_a, numericality: { greater_than_or_equal_to: 0 }
  validates :burden_b, numericality: { greater_than_or_equal_to: 0 }

  def shared?
    burden_a + burden_b > 0
  end
end
