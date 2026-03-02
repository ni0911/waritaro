require 'rails_helper'

RSpec.describe "Settings", type: :request do
  describe "GET /setting" do
    it "200 を返す" do
      get setting_path
      expect(response).to have_http_status(:ok)
    end

    it "Setting が存在しない場合でも 200 を返す（自動作成）" do
      Setting.delete_all
      get setting_path
      expect(response).to have_http_status(:ok)
      expect(Setting.count).to eq(1)
    end
  end

  describe "PATCH /setting" do
    context "有効なパラメーター" do
      it "更新してリダイレクト" do
        patch setting_path, params: { setting: { member_a: "太郎", member_b: "花子" } }
        expect(response).to redirect_to(setting_path)
        expect(Setting.instance.member_a).to eq("太郎")
        expect(Setting.instance.member_b).to eq("花子")
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        patch setting_path, params: { setting: { member_a: "", member_b: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
