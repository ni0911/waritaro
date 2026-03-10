require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /register" do
    it "200 を返す" do
      get new_registration_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /register" do
    context "有効なパラメーター" do
      it "ユーザーを作成してグループ設定ページにリダイレクト" do
        expect {
          post registrations_path, params: {
            user: { email_address: "new@example.com", password: "password123", password_confirmation: "password123" }
          }
        }.to change(User, :count).by(1)
        expect(response).to redirect_to(new_group_setting_path)
      end
    end

    context "無効なパラメーター（メールアドレスなし）" do
      it "422 を返す" do
        post registrations_path, params: {
          user: { email_address: "", password: "password123", password_confirmation: "password123" }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
