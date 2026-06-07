module Api
  module V1
    # SettlementService::Result の JSON 表現（ADR 0012 / alba）。
    class SettlementSerializer
      include Alba::Resource

      attributes :deposit_a, :deposit_b, :total_shared_amount
    end
  end
end
