class Sheet < ApplicationRecord
  YEAR_MONTH_FORMAT = /\A\d{4}-(0[1-9]|1[0-2])\z/

  has_many :sheet_items, dependent: :destroy

  validates :year_month, presence: true,
                         uniqueness: true,
                         format: { with: YEAR_MONTH_FORMAT }

  def label
    year, month = year_month.split("-")
    "#{year}年#{month.to_i}月"
  end
end
