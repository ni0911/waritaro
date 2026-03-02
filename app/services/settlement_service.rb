class SettlementService
  Result = Data.define(:transfer_a, :transfer_b, :total_shared_amount, :burden_a, :burden_b, :paid_a, :paid_b)

  def initialize(sheet)
    @sheet = sheet
  end

  def calculate
    shared_items = @sheet.sheet_items.select { |i| i.burden_a + i.burden_b > 0 }

    total_burden_a = shared_items.sum(&:burden_a)
    total_burden_b = shared_items.sum(&:burden_b)
    total_paid_a   = shared_items.select { |i| i.payer == "A" }.sum(&:amount)
    total_paid_b   = shared_items.select { |i| i.payer == "B" }.sum(&:amount)

    transfer_a = total_burden_a - total_paid_a
    transfer_b = total_burden_b - total_paid_b

    Result.new(
      transfer_a:,
      transfer_b:,
      total_shared_amount: total_burden_a + total_burden_b,
      burden_a: total_burden_a,
      burden_b: total_burden_b,
      paid_a: total_paid_a,
      paid_b: total_paid_b
    )
  end
end
