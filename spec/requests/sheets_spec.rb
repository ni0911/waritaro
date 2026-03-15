require 'rails_helper'

RSpec.describe "Sheets", type: :request do
  let(:setting) { create(:setting) }
  let(:user) { create(:user, setting: setting) }
  before { sign_in(user) }

  describe "GET /" do
    it "200 を返す" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "シートが複数ある場合、新しい順に表示" do
      create(:sheet, year_month: "2026-01", setting: setting)
      create(:sheet, year_month: "2026-03", setting: setting)
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
        create(:sheet, year_month: "2026-03", setting: setting)
        expect {
          post sheets_path, params: { sheet: { year_month: "2026-03" } }
        }.not_to change(Sheet, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /sheets/:year_month" do
    it "削除してルートにリダイレクト" do
      sheet = create(:sheet, year_month: "2026-03", setting: setting)
      expect {
        delete sheet_path("2026-03")
      }.to change(Sheet, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST /sheets/:year_month/apply_template" do
    let!(:sheet)    { create(:sheet, year_month: "2026-04", setting: setting) }
    let!(:template) { create(:template_item, name: "家賃", amount: 120000, burden_a: 80000, burden_b: 40000, setting: setting) }

    it "テンプレートをシートに適用してリダイレクト" do
      expect {
        post apply_template_sheet_path("2026-04")
      }.to change(SheetItem, :count).by(1)
      expect(response).to redirect_to(settlement_sheet_path("2026-04"))
      item = SheetItem.last
      expect(item.name).to eq("家賃")
      expect(item.is_from_template).to be true
    end

    it "複数テンプレートがある場合、すべて適用する" do
      create(:template_item, name: "食費", amount: 30000, burden_a: 15000, burden_b: 15000, setting: setting)
      expect {
        post apply_template_sheet_path("2026-04")
      }.to change(SheetItem, :count).by(2)
    end

    it "2回呼んでも SheetItem が重複しない" do
      post apply_template_sheet_path("2026-04")
      expect {
        post apply_template_sheet_path("2026-04")
      }.not_to change(SheetItem, :count)
    end

    it "既に適用済みのときは alert でリダイレクト" do
      post apply_template_sheet_path("2026-04")
      post apply_template_sheet_path("2026-04")
      expect(response).to redirect_to(settlement_sheet_path("2026-04"))
      expect(flash[:alert]).to match(/既に適用済み/)
    end
  end

  describe "GET /sheets/:year_month/settlement" do
    it "200 を返す" do
      create(:sheet, year_month: "2026-03", setting: setting)
      get settlement_sheet_path("2026-03")
      expect(response).to have_http_status(:ok)
    end

    it "費目別内訳にアイテム名と金額が表示される" do
      sheet = create(:sheet, year_month: "2026-06", setting: setting)
      create(:sheet_item, sheet: sheet, name: "家賃", amount: 60000, burden_a: 40000, burden_b: 20000)
      create(:sheet_item, sheet: sheet, name: "食費", amount: 5000, burden_a: 2500, burden_b: 2500)
      get settlement_sheet_path("2026-06")
      expect(response.body).to include("費目別内訳")
      expect(response.body).to include("家賃")
      expect(response.body).to include("食費")
    end
  end
end
