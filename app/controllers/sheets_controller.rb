class SheetsController < ApplicationController
  before_action :set_sheet, only: [ :destroy, :settlement, :apply_template ]

  def index
    @sheets = current_setting.sheets.order(year_month: :desc)
  end

  def create
    @sheet = current_setting.sheets.new(sheet_params)
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
    @sheet_items = @sheet.sheet_items.includes(:card)
    @result      = SettlementService.new(@sheet).calculate
    @cards       = current_setting.cards.index_by(&:id)
    @share_text  = ShareTextService.new(@sheet, @setting, current_setting.cards).generate
  end

  def apply_template
    current_setting.template_items.each do |tmpl|
      @sheet.sheet_items.create!(
        name:               tmpl.name,
        amount:             tmpl.amount,
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
    @sheet = current_setting.sheets.find_by!(year_month: params[:year_month])
  end

  def sheet_params
    params.require(:sheet).permit(:year_month)
  end
end
