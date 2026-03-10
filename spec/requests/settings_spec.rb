require 'rails_helper'

RSpec.describe "Settings", type: :request do
  let(:setting) { create(:setting) }
  let(:user) { create(:user, setting: setting) }
  before { sign_in(user) }

  describe "GET /setting" do
    it "200 を返す" do
      get setting_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /setting" do
    context "有効なパラメーター" do
      it "更新してリダイレクト" do
        patch setting_path, params: { setting: { member_a: "太郎", member_b: "花子" } }
        expect(response).to redirect_to(setting_path)
        expect(setting.reload.member_a).to eq("太郎")
        expect(setting.reload.member_b).to eq("花子")
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        patch setting_path, params: { setting: { member_a: "", member_b: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "POST /setting/join（招待コードで参加）" do
    let(:target_setting) { create(:setting) }

    context "グループ未所属のユーザーが正しい招待コードで参加" do
      let(:user) { create(:user, setting: nil) }

      it "グループに参加してルートにリダイレクト" do
        sign_in(user)
        post join_setting_path, params: { invite_code: target_setting.invite_code }
        expect(response).to redirect_to(root_path)
        expect(user.reload.setting).to eq(target_setting)
      end
    end

    context "既にグループに所属しているユーザーが参加しようとする" do
      it "設定画面にリダイレクトされ参加できない" do
        post join_setting_path, params: { invite_code: target_setting.invite_code }
        expect(response).to redirect_to(setting_path)
        expect(user.reload.setting).to eq(setting)  # 元のまま変わらない
      end
    end

    context "グループが満員（2人）の場合" do
      let(:user) { create(:user, setting: nil) }

      before do
        # target_setting にすでに2人いる状態
        create(:user, setting: target_setting)  # オーナーとして1人目
        create(:user, setting: target_setting)  # 2人目
        sign_in(user)
      end

      it "422 を返して参加できない" do
        post join_setting_path, params: { invite_code: target_setting.invite_code }
        expect(response).to have_http_status(:unprocessable_content)
        expect(user.reload.setting).to be_nil
      end
    end

    context "存在しない招待コード" do
      let(:user) { create(:user, setting: nil) }

      it "422 を返す" do
        sign_in(user)
        post join_setting_path, params: { invite_code: "invalid_code" }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
