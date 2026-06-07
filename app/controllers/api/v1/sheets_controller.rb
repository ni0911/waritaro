module Api
  module V1
    class SheetsController < BaseController
      # GET /api/v1/sheets
      def index
        scope        = current_setting.sheets.order(year_month: :desc)
        sheets, meta = paginate(scope)

        render json: {
          sheets:     SheetSerializer.new(sheets).serializable_hash,
          pagination: meta
        }
      end

      # GET /api/v1/sheets/:year_month/settlement
      def settlement
        sheet  = current_setting.sheets.find_by!(year_month: params[:year_month])
        result = SettlementService.new(sheet).calculate

        render json: {
          sheet:      SheetSerializer.new(sheet).serializable_hash,
          settlement: SettlementSerializer.new(result).serializable_hash
        }
      end
    end
  end
end
