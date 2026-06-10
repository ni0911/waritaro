class SheetItem < ApplicationRecord
  belongs_to :sheet
  belongs_to :card, optional: true
  belongs_to :template_item, optional: true

  validates :name, presence: true
  validates :amount,   numericality: { greater_than_or_equal_to: 0 }
  validates :burden_a, numericality: { greater_than_or_equal_to: 0 }
  validates :burden_b, numericality: { greater_than_or_equal_to: 0 }
  validates :template_item_id, uniqueness: { scope: :sheet_id }, allow_nil: true
  validate  :burden_sum_positive
  validate  :card_belongs_to_same_setting

  private

  def burden_sum_positive
    errors.add(:base, "負担額の合計は 1 円以上にしてください") if burden_a.to_i + burden_b.to_i <= 0
  end

  # card は sheet と同じグループ（setting）のものでなければならない（テナント分離）。
  def card_belongs_to_same_setting
    return if card.nil? || sheet.nil?
    return if card.setting_id == sheet.setting_id

    errors.add(:card, "は同じグループのカードを指定してください")
  end
end
