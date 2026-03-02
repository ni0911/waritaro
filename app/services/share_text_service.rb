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
        lines << "  #{item.name}：#{number_to_delimited(item.amount)}円（#{label(item.payer)}払い / #{card_name(item.card_id)}）"
        lines << "    #{label('A')}負担：#{number_to_delimited(item.burden_a)}円　#{label('B')}負担：#{number_to_delimited(item.burden_b)}円"
      end
      lines << "  合計：#{number_to_delimited(result.total_shared_amount)}円"
      lines << ""
    end

    private_items = @sheet.sheet_items.select { |i| i.burden_a + i.burden_b == 0 }
    if private_items.any?
      lines << "■ 私物（対象外）"
      private_items.each do |item|
        lines << "  #{item.name}：#{number_to_delimited(item.amount)}円（#{label(item.payer)}払い）"
      end
      lines << ""
    end

    lines << "■ 負担額"
    lines << "  #{label('A')}：#{number_to_delimited(result.burden_a)}円"
    lines << "  #{label('B')}：#{number_to_delimited(result.burden_b)}円"
    lines << ""

    lines << "■ 精算"
    lines << format_transfer(label('A'), result.transfer_a)
    lines << format_transfer(label('B'), result.transfer_b)

    lines.join("\n")
  end

  private

  def label(member)
    member == 'A' ? @setting.member_a : @setting.member_b
  end

  def card_name(card_id)
    return "現金" if card_id.nil?
    @cards.find { |c| c.id == card_id }&.name || "不明カード"
  end

  def format_year_month(year_month)
    year, month = year_month.split('-')
    "#{year}年#{month.to_i}月"
  end

  def format_transfer(name, amount)
    if amount > 0
      "  #{name} → 共有口座 へ #{number_to_delimited(amount)}円"
    elsif amount < 0
      "  #{name} ← 共有口座 から #{number_to_delimited(amount.abs)}円（来月分から調整）"
    else
      "  #{name}：精算なし"
    end
  end
end
