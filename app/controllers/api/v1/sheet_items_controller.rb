module Api
  module V1
    class SheetItemsController < BaseController
      # POST /api/v1/sheets/:sheet_year_month/sheet_items
      def create
        sheet = current_setting.sheets.find_by!(year_month: params[:sheet_year_month])
        item  = sheet.sheet_items.build(sheet_item_params)

        if item.save
          render json: SheetItemSerializer.new(item).serialize, status: :created
        else
          render_validation_errors(item)
        end
      end

      private

      def sheet_item_params
        params.require(:sheet_item).permit(:name, :amount, :burden_a, :burden_b, :card_id)
      end
    end
  end
end
