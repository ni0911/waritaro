class Sheet < ApplicationRecord
  YEAR_MONTH_FORMAT = /\A\d{4}-(0[1-9]|1[0-2])\z/

  belongs_to :setting
  has_many :sheet_items, dependent: :destroy

  validates :year_month, presence: true,
                         uniqueness: { scope: :setting_id },
                         format: { with: YEAR_MONTH_FORMAT }

  def label
    year, month = year_month.split("-")
    "#{year}年#{month.to_i}月"
  end
end
