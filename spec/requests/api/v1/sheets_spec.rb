require 'rails_helper'

RSpec.describe "Api::V1::Sheets", type: :request do
  let(:setting) { create(:setting) }
  let(:user)    { create(:user, setting: setting) }

  describe "GET /api/v1/sheets" do
    context "未認証" do
      it "401 と error JSON を返す" do
        get "/api/v1/sheets"
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body.dig("error", "code")).to eq("unauthorized")
      end
    end

    context "認証あり" do
      before { sign_in(user) }

      it "200 と JSON を返す" do
        get "/api/v1/sheets"
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq("application/json")
      end

      it "自グループのシートを新しい順に返す" do
        create(:sheet, year_month: "2026-01", setting: setting)
        create(:sheet, year_month: "2026-03", setting: setting)

        get "/api/v1/sheets"

        sheets = response.parsed_body.fetch("sheets")
        expect(sheets.map { |s| s["year_month"] }).to eq(%w[2026-03 2026-01])
        expect(sheets.first).to include("id", "year_month", "label")
        expect(sheets.first["label"]).to eq("2026年3月")
      end

      it "他グループのシートは含めない（テナント分離）" do
        other_setting = create(:setting)
        create(:sheet, year_month: "2026-05", setting: other_setting)
        create(:sheet, year_month: "2026-02", setting: setting)

        get "/api/v1/sheets"

        year_months = response.parsed_body.fetch("sheets").map { |s| s["year_month"] }
        expect(year_months).to contain_exactly("2026-02")
      end
    end

    context "グループ未所属のユーザー" do
      let(:no_group_user) { create(:user, setting: nil) }
      before { sign_in(no_group_user) }

      it "403 と error JSON を返す" do
        get "/api/v1/sheets"
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body.dig("error", "code")).to eq("forbidden")
      end
    end
  end

  describe "GET /api/v1/sheets/:year_month/settlement" do
    let(:sheet) { create(:sheet, year_month: "2026-03", setting: setting) }

    context "未認証" do
      it "401 と error JSON を返す" do
        get "/api/v1/sheets/#{sheet.year_month}/settlement"
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body.dig("error", "code")).to eq("unauthorized")
      end
    end

    context "認証あり" do
      before { sign_in(user) }

      it "200 とシート情報・精算結果を返す" do
        create(:sheet_item, sheet: sheet, amount: 5000, burden_a: 3000, burden_b: 2000)
        create(:sheet_item, sheet: sheet, amount: 4000, burden_a: 1000, burden_b: 3000)

        get "/api/v1/sheets/#{sheet.year_month}/settlement"

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body.dig("sheet", "year_month")).to eq("2026-03")
        expect(body.dig("sheet", "label")).to eq("2026年3月")
        expect(body.dig("settlement", "deposit_a")).to eq(4000)
        expect(body.dig("settlement", "deposit_b")).to eq(5000)
        expect(body.dig("settlement", "total_shared_amount")).to eq(9000)
      end

      it "片方のみ負担（私物寄り）の費用も負担額どおり集計する" do
        create(:sheet_item, sheet: sheet, amount: 3000, burden_a: 3000, burden_b: 0)

        get "/api/v1/sheets/#{sheet.year_month}/settlement"

        body = response.parsed_body
        expect(body.dig("settlement", "deposit_a")).to eq(3000)
        expect(body.dig("settlement", "deposit_b")).to eq(0)
        expect(body.dig("settlement", "total_shared_amount")).to eq(3000)
      end

      it "存在しない年月は 404 と error JSON を返す" do
        get "/api/v1/sheets/2099-12/settlement"
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body.dig("error", "code")).to eq("not_found")
      end

      it "他グループのシートは 404（テナント分離）" do
        other_setting = create(:setting)
        other_sheet   = create(:sheet, year_month: "2026-07", setting: other_setting)

        get "/api/v1/sheets/#{other_sheet.year_month}/settlement"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
