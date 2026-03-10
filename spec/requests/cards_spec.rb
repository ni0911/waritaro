require 'rails_helper'

RSpec.describe "Cards", type: :request do
  let(:setting) { create(:setting) }
  let(:user) { create(:user, setting: setting) }
  before { sign_in(user) }

  describe "GET /cards" do
    it "200 を返す" do
      create_list(:card, 3, setting: setting)
      get cards_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /cards/new" do
    it "200 を返す" do
      get new_card_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /cards" do
    context "有効なパラメーター" do
      it "作成してリダイレクト" do
        expect {
          post cards_path, params: { card: { name: "楽天カード", owner: "A" } }
        }.to change(Card, :count).by(1)
        expect(response).to redirect_to(cards_path)
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        post cards_path, params: { card: { name: "", owner: "A" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /cards/:id/edit" do
    it "200 を返す" do
      card = create(:card, setting: setting)
      get edit_card_path(card)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /cards/:id" do
    let(:card) { create(:card, name: "旧カード", setting: setting) }

    context "有効なパラメーター" do
      it "更新してリダイレクト" do
        patch card_path(card), params: { card: { name: "新カード", owner: "B" } }
        expect(response).to redirect_to(cards_path)
        expect(card.reload.name).to eq("新カード")
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        patch card_path(card), params: { card: { name: "", owner: "A" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /cards/:id" do
    it "削除して Turbo Stream で応答" do
      card = create(:card, setting: setting)
      expect {
        delete card_path(card), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Card, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "削除してリダイレクト（通常）" do
      card = create(:card, setting: setting)
      expect {
        delete card_path(card)
      }.to change(Card, :count).by(-1)
      expect(response).to redirect_to(cards_path)
    end
  end
end
