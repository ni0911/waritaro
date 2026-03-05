class ShareTextService
  include ActiveSupport::NumberHelper

  def initialize(sheet, setting, cards)
    @sheet   = sheet
    @setting = setting
    @cards   = cards
  end

  def generate
    result = SettlementService.new(@sheet).calculate
    lines = []

    lines << "【#{format_year_month(@sheet.year_month)} 精算】"
    lines << ""

    shared_items = @sheet.sheet_items.select { |i| i.burden_a + i.burden_b > 0 }
    if shared_items.any?
      lines << "■ 精算対象"
      shared_items.each do |item|
        lines << "  #{item.name}：#{number_to_delimited(item.amount)}円（#{card_name(item.card_id)}）"
        lines << "    #{@setting.member_a}負担：#{number_to_delimited(item.burden_a)}円　#{@setting.member_b}負担：#{number_to_delimited(item.burden_b)}円"
      end
      lines << "  合計：#{number_to_delimited(result.total_shared_amount)}円"
      lines << ""
    end

    private_items = @sheet.sheet_items.select { |i| i.burden_a + i.burden_b == 0 }
    if private_items.any?
      lines << "■ 私物（対象外）"
      private_items.each do |item|
        lines << "  #{item.name}：#{number_to_delimited(item.amount)}円"
      end
      lines << ""
    end

    lines << "■ 負担額"
    lines << "  #{@setting.member_a}：#{number_to_delimited(result.deposit_a)}円"
    lines << "  #{@setting.member_b}：#{number_to_delimited(result.deposit_b)}円"
    lines << ""

    lines << "■ 精算"
    lines << format_deposit(@setting.member_a, result.deposit_a)
    lines << format_deposit(@setting.member_b, result.deposit_b)

    lines.join("\n")
  end

  private

  def card_name(card_id)
    return "現金" if card_id.nil?
    @cards.find { |c| c.id == card_id }&.name || "不明カード"
  end

  def format_year_month(year_month)
    year, month = year_month.split("-")
    "#{year}年#{month.to_i}月"
  end

  def format_deposit(name, amount)
    if amount > 0
      "  #{name} → 共有口座 へ #{number_to_delimited(amount)}円"
    else
      "  #{name}：精算なし"
    end
  end
end
