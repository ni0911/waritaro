class Settlement < ApplicationRecord
  belongs_to :group
  has_many :expenses, dependent: :nullify

  validates :settled_at, presence: true
end
