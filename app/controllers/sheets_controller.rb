class SheetsController < ApplicationController
  before_action :set_sheet, only: [:destroy, :settlement, :apply_template]

  def index
    @sheets = Sheet.order(year_month: :desc)
  end

  def create
    @sheet = Sheet.new(sheet_params)
    if @sheet.save
      redirect_to settlement_sheet_path(@sheet.year_month)
    else
      redirect_to root_path, alert: "#{sheet_params[:year_month]} は既に存在します"
    end
  end

  def destroy
    @sheet.destroy
    redirect_to root_path, notice: "#{@sheet.label} を削除しました"
  end

  def settlement
    @result = SettlementService.new(@sheet).calculate
    @cards  = Card.all.index_by(&:id)
    @share_text = ShareTextService.new(@sheet, @setting, Card.all).generate
  end

  def apply_template
    TemplateItem.all.each do |tmpl|
      @sheet.sheet_items.create!(
        name:               tmpl.name,
        amount:             tmpl.amount,
        payer:              tmpl.payer,
        burden_a:           tmpl.burden_a,
        burden_b:           tmpl.burden_b,
        card_id:            tmpl.card_id,
        is_from_template:   true,
        template_item_id:   tmpl.id
      )
    end
    redirect_to settlement_sheet_path(@sheet.year_month), notice: "テンプレートを適用しました"
  end

  private

  def set_sheet
    @sheet = Sheet.find_by!(year_month: params[:year_month])
  end

  def sheet_params
    params.require(:sheet).permit(:year_month)
  end
end
