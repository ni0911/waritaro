class SettlementService
  Result = Data.define(:deposit_a, :deposit_b, :total_shared_amount)

  def initialize(sheet)
    @sheet = sheet
  end

  def calculate
    shared_items = @sheet.sheet_items.select { |i| i.burden_a + i.burden_b > 0 }

    deposit_a = shared_items.sum(&:burden_a)
    deposit_b = shared_items.sum(&:burden_b)

    Result.new(
      deposit_a:,
      deposit_b:,
      total_shared_amount: deposit_a + deposit_b
    )
  end
end
