require 'rails_helper'

RSpec.describe "Sheets", type: :request do
  describe "GET /" do
    it "200 を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "シートが複数ある場合、新しい順に表示" do
      create(:sheet, year_month: "2026-01")
      create(:sheet, year_month: "2026-03")
      get root_path
      expect(response.body).to match(/2026年3月.*2026年1月/m)
    end
  end

  describe "POST /sheets" do
    context "有効なパラメーター" do
      it "作成してシート画面にリダイレクト" do
        expect {
          post sheets_path, params: { sheet: { year_month: "2026-05" } }
        }.to change(Sheet, :count).by(1)
        expect(response).to redirect_to(settlement_sheet_path("2026-05"))
      end
    end

    context "重複する year_month" do
      it "作成せずルートにリダイレクト" do
        create(:sheet, year_month: "2026-03")
        expect {
          post sheets_path, params: { sheet: { year_month: "2026-03" } }
        }.not_to change(Sheet, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /sheets/:year_month" do
    it "削除してルートにリダイレクト" do
      sheet = create(:sheet, year_month: "2026-03")
      expect {
        delete sheet_path("2026-03")
      }.to change(Sheet, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /sheets/:year_month/apply_template" do
    let!(:sheet)    { create(:sheet, year_month: "2026-04") }
    let!(:template) { create(:template_item, name: "家賃", amount: 120000, payer: "A", burden_a: 80000, burden_b: 40000) }

    it "テンプレートをシートに適用してリダイレクト" do
      expect {
        post apply_template_sheet_path("2026-04")
      }.to change(SheetItem, :count).by(1)
      expect(response).to redirect_to(settlement_sheet_path("2026-04"))
      item = SheetItem.last
      expect(item.name).to eq("家賃")
      expect(item.is_from_template).to be true
    end
  end

  describe "GET /sheets/:year_month/settlement" do
    it "200 を返す" do
      create(:sheet, year_month: "2026-03")
      Setting.instance
      get settlement_sheet_path("2026-03")
      expect(response).to have_http_status(:ok)
    end
  end
end
