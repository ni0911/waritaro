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
    existing_template_ids = @sheet.sheet_items.where.not(template_item_id: nil).pluck(:template_item_id).to_set

    new_items = current_setting.template_items
      .reject { |tmpl| existing_template_ids.include?(tmpl.id) }
      .map { |tmpl|
        {
          sheet_id:         @sheet.id,
          name:             tmpl.name,
          amount:           tmpl.amount,
          burden_a:         tmpl.burden_a,
          burden_b:         tmpl.burden_b,
          card_id:          tmpl.card_id,
          is_from_template: true,
          template_item_id: tmpl.id
        }
      }

    if new_items.any?
      SheetItem.insert_all!(new_items)
      redirect_to settlement_sheet_path(@sheet.year_month), notice: "テンプレートを適用しました"
    else
      redirect_to settlement_sheet_path(@sheet.year_month), alert: "テンプレートは既に適用済みです"
    end
  end

  private

  def set_sheet
    @sheet = current_setting.sheets.find_by!(year_month: params[:year_month])
  end

  def sheet_params
    params.require(:sheet).permit(:year_month)
  end
end
