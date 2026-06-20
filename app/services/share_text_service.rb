# グループの最小送金プランを LINE 貼り付け用テキストへ整形する（ADR 0013）。
# デザインの buildGroupSettleText 相当。全角スペースで名前と金額を区切る。
class ShareTextService
  DIVIDER = "――――――――".freeze

  def initialize(group)
    @group = group
  end

  def group_settlement
    transfers = SettlementService.new(@group).plan.transfers

    lines = [ "【#{@group.name}】#{@group.icon} の精算", DIVIDER ]
    if transfers.empty?
      lines << "🎉 精算は完了しています！"
    else
      transfers.each do |t|
        lines << "#{t.from.name} → #{t.to.name}　#{yen(t.amount)}"
      end
      lines << DIVIDER
      lines << "送金は #{transfers.size} 回でOK ✿"
    end
    lines << "waritaro"
    lines.join("\n")
  end

  private

  def yen(amount)
    "¥#{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
