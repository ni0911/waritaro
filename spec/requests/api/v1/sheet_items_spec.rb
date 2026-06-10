require 'rails_helper'

RSpec.describe "Api::V1::SheetItems", type: :request do
  let(:setting) { create(:setting) }
  let(:user)    { create(:user, setting: setting) }
  let(:sheet)   { create(:sheet, year_month: "2026-03", setting: setting) }

  describe "POST /api/v1/sheets/:year_month/sheet_items" do
    let(:valid_params) do
      { sheet_item: { name: "電気代", amount: 8000, burden_a: 4000, burden_b: 4000 } }
    end

    context "未認証" do
      it "401 と error JSON を返す" do
        post "/api/v1/sheets/#{sheet.year_month}/sheet_items", params: valid_params
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body.dig("error", "code")).to eq("unauthorized")
      end
    end

    context "認証あり" do
      before { sign_in(user) }

      it "201 と作成された費用 JSON を返す" do
        expect {
          post "/api/v1/sheets/#{sheet.year_month}/sheet_items", params: valid_params
        }.to change(sheet.sheet_items, :count).by(1)

        expect(response).to have_http_status(:created)
        item = response.parsed_body.fetch("sheet_item")
        expect(item).to include("id", "name", "amount", "burden_a", "burden_b")
        expect(item["name"]).to eq("電気代")
        expect(item["amount"]).to eq(8000)
      end

      it "自グループの card_id なら紐付けて 201 を返す" do
        card = create(:card, setting: setting)

        post "/api/v1/sheets/#{sheet.year_month}/sheet_items",
             params: { sheet_item: valid_params[:sheet_item].merge(card_id: card.id) }

        expect(response).to have_http_status(:created)
        expect(response.parsed_body.dig("sheet_item", "card_id")).to eq(card.id)
      end

      it "他グループの card_id は紐付けられず 422（テナント分離）" do
        other_card = create(:card, setting: create(:setting))

        expect {
          post "/api/v1/sheets/#{sheet.year_month}/sheet_items",
               params: { sheet_item: valid_params[:sheet_item].merge(card_id: other_card.id) }
        }.not_to change(SheetItem, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.dig("error", "code")).to eq("unprocessable_content")
      end

      it "不正なパラメータは 422 とバリデーションエラーを返す" do
        invalid = { sheet_item: { name: "", amount: 8000, burden_a: 0, burden_b: 0 } }

        expect {
          post "/api/v1/sheets/#{sheet.year_month}/sheet_items", params: invalid
        }.not_to change(SheetItem, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body.dig("error", "code")).to eq("unprocessable_content")
        expect(response.parsed_body.dig("error", "details")).to be_present
      end

      it "必須パラメータ(sheet_item)が無いと 400 と error JSON を返す" do
        post "/api/v1/sheets/#{sheet.year_month}/sheet_items", params: {}
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body.dig("error", "code")).to eq("bad_request")
      end

      it "存在しない年月は 404 を返す" do
        post "/api/v1/sheets/2099-12/sheet_items", params: valid_params
        expect(response).to have_http_status(:not_found)
      end

      it "他グループのシートには追加できない（テナント分離・404）" do
        other_setting = create(:setting)
        other_sheet   = create(:sheet, year_month: "2026-07", setting: other_setting)

        expect {
          post "/api/v1/sheets/#{other_sheet.year_month}/sheet_items", params: valid_params
        }.not_to change(SheetItem, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
