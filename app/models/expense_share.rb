class ExpenseShare < ApplicationRecord
  belongs_to :expense
  belongs_to :member

  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :member_id, uniqueness: { scope: :expense_id }
end
