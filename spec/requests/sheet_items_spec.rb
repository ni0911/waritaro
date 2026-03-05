require 'rails_helper'

RSpec.describe "SheetItems", type: :request do
  let(:sheet) { create(:sheet, year_month: "2026-03") }

  describe "POST /sheets/:year_month/sheet_items" do
    context "有効なパラメーター" do
      it "作成して Turbo Stream で応答" do
        expect {
          post sheet_sheet_items_path(sheet.year_month),
               params: { sheet_item: { name: "食費", amount: 5000, burden_a: 2500, burden_b: 2500 } },
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
        }.to change(SheetItem, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        post sheet_sheet_items_path(sheet.year_month),
             params: { sheet_item: { name: "", amount: 0, burden_a: 0, burden_b: 0 } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /sheets/:year_month/sheet_items/:id" do
    it "削除して Turbo Stream で応答" do
      item = create(:sheet_item, sheet: sheet)
      expect {
        delete sheet_sheet_item_path(sheet.year_month, item),
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(SheetItem, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /sheets/:year_month/sheet_items/:id/update_burden" do
    let(:item) { create(:sheet_item, sheet: sheet, burden_a: 1000, burden_b: 1000) }

    it "burden を更新して Turbo Stream で応答" do
      patch update_burden_sheet_sheet_item_path(sheet.year_month, item),
            params: { sheet_item: { burden_a: 3000, burden_b: 2000 } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(item.reload.burden_a).to eq(3000)
      expect(item.reload.burden_b).to eq(2000)
    end
  end

  describe "PATCH /sheets/:year_month/sheet_items/:id/update_amount" do
    let(:item) { create(:sheet_item, sheet: sheet, amount: 5000, burden_a: 2500, burden_b: 2500) }

    it "金額を更新して Turbo Stream で応答" do
      patch update_amount_sheet_sheet_item_path(sheet.year_month, item),
            params: { sheet_item: { amount: 8000 } },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:ok)
      expect(item.reload.amount).to eq(8000)
    end
  end
end
