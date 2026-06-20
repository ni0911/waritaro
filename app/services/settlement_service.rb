# グループの未精算費用から、各メンバーの純収支を求め、
# 最小回数の送金プラン（debt simplification）を貪欲法で算出する。
#
#   net(member) = Σ(自分が payer の Expense.amount) − Σ(自分の ExpenseShare.amount)
#   net > 0 … 受け取るべき / net < 0 … 支払うべき / Σ net = 0
#
# 2者の場合は旧 deposit モデルと一致する（ADR 0013 / 後方互換）。
class SettlementService
  Transfer = Data.define(:from, :to, :amount) # from / to は Member
  Plan     = Data.define(:transfers, :nets)   # nets は { member => net }

  def initialize(group)
    @group = group
  end

  def plan
    nets = compute_nets
    members_by_id = @group.members.index_by(&:id)

    transfers = self.class.minimize_transfers(nets.transform_keys(&:id)).map do |t|
      Transfer.new(
        from:   members_by_id[t[:from]],
        to:     members_by_id[t[:to]],
        amount: t[:amount]
      )
    end

    Plan.new(transfers:, nets:)
  end

  # 純粋ロジック: { key => net(整数) } → [{ from:, to:, amount: }]
  # キーの型は任意（id でもオブジェクトでも可）。
  def self.minimize_transfers(nets)
    creditors = []
    debtors   = []
    nets.each do |key, value|
      v = value.round
      if v.positive?
        creditors << { key:, amt: v }
      elsif v.negative?
        debtors << { key:, amt: -v }
      end
    end
    # 金額降順。同額時はキーで安定ソート（決定性のため）
    sort = ->(a, b) { [ b[:amt], a[:key].to_s ] <=> [ a[:amt], b[:key].to_s ] }
    creditors.sort!(&sort)
    debtors.sort!(&sort)

    transfers = []
    i = j = 0
    while i < debtors.size && j < creditors.size
      pay = [ debtors[i][:amt], creditors[j][:amt] ].min
      transfers << { from: debtors[i][:key], to: creditors[j][:key], amount: pay } if pay.positive?
      debtors[i][:amt]   -= pay
      creditors[j][:amt] -= pay
      i += 1 if debtors[i][:amt].zero?
      j += 1 if creditors[j][:amt].zero?
    end
    transfers
  end

  private

  # { member => net } を未精算費用から算出
  def compute_nets
    nets = @group.members.to_h { |m| [ m, 0 ] }
    member_by_id = @group.members.index_by(&:id)

    expenses = @group.open_expenses.includes(:shares)
    expenses.each do |expense|
      payer = member_by_id[expense.payer_id]
      nets[payer] += expense.amount if payer
      expense.shares.each do |share|
        member = member_by_id[share.member_id]
        nets[member] -= share.amount if member
      end
    end
    nets
  end
end
