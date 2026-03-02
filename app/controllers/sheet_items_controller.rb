class SheetItemsController < ApplicationController
  before_action :set_sheet
  before_action :set_item, only: [:destroy, :update_burden, :update_amount]

  def create
    @sheet_item = @sheet.sheet_items.build(sheet_item_params)
    if @sheet_item.save
      render turbo_stream: [
        turbo_stream.append("sheet_items_list",
          partial: "sheet_items/sheet_item",
          locals: { sheet_item: @sheet_item, sheet: @sheet }),
        turbo_stream.replace("new_sheet_item",
          partial: "sheet_items/form",
          locals: { sheet: @sheet })
      ]
    else
      render turbo_stream: turbo_stream.replace("new_sheet_item",
        partial: "sheet_items/form",
        locals: { sheet: @sheet, sheet_item: @sheet_item }),
        status: :unprocessable_content
    end
  end

  def destroy
    @sheet_item.destroy
    render turbo_stream: turbo_stream.remove("sheet_item_#{@sheet_item.id}")
  end

  def update_burden
    @sheet_item.update!(burden_params)
    render turbo_stream: turbo_stream.replace(
      "sheet_item_#{@sheet_item.id}",
      partial: "sheet_items/sheet_item",
      locals: { sheet_item: @sheet_item, sheet: @sheet }
    )
  end

  def update_amount
    @sheet_item.update!(amount_params)
    render turbo_stream: turbo_stream.replace(
      "sheet_item_#{@sheet_item.id}",
      partial: "sheet_items/sheet_item",
      locals: { sheet_item: @sheet_item, sheet: @sheet }
    )
  end

  private

  def set_sheet
    @sheet = Sheet.find_by!(year_month: params[:sheet_year_month])
  end

  def set_item
    @sheet_item = @sheet.sheet_items.find(params[:id])
  end

  def sheet_item_params
    params.require(:sheet_item).permit(:name, :amount, :payer, :burden_a, :burden_b, :card_id)
  end

  def burden_params
    params.require(:sheet_item).permit(:burden_a, :burden_b)
  end

  def amount_params
    params.require(:sheet_item).permit(:amount)
  end
end
