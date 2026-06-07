module Api
  module V1
    # Sheet の JSON 表現（ADR 0012 / alba）。
    class SheetSerializer
      include Alba::Resource

      root_key :sheet, :sheets

      attributes :id, :year_month

      attribute :label do |sheet|
        sheet.label
      end
    end
  end
end
