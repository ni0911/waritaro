require 'rails_helper'

RSpec.describe "TemplateItems", type: :request do
  describe "GET /template_items" do
    it "200 を返す" do
      create_list(:template_item, 3)
      get template_items_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /template_items/new" do
    it "200 を返す" do
      get new_template_item_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /template_items" do
    context "有効なパラメーター" do
      it "作成してリダイレクト" do
        expect {
          post template_items_path, params: {
            template_item: { name: "家賃", amount: 120000, payer: "A", burden_a: 80000, burden_b: 40000 }
          }
        }.to change(TemplateItem, :count).by(1)
        expect(response).to redirect_to(template_items_path)
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        post template_items_path, params: {
          template_item: { name: "", amount: 0, payer: "A", burden_a: 0, burden_b: 0 }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "GET /template_items/:id/edit" do
    it "200 を返す" do
      item = create(:template_item)
      get edit_template_item_path(item)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /template_items/:id" do
    let(:item) { create(:template_item, name: "旧名前") }

    context "有効なパラメーター" do
      it "更新してリダイレクト" do
        patch template_item_path(item), params: {
          template_item: { name: "新名前", amount: 5000, payer: "B", burden_a: 2500, burden_b: 2500 }
        }
        expect(response).to redirect_to(template_items_path)
        expect(item.reload.name).to eq("新名前")
      end
    end

    context "無効なパラメーター" do
      it "422 を返す" do
        patch template_item_path(item), params: {
          template_item: { name: "", amount: 0, payer: "A", burden_a: 0, burden_b: 0 }
        }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /template_items/:id" do
    it "削除して Turbo Stream で応答" do
      item = create(:template_item)
      expect {
        delete template_item_path(item), headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(TemplateItem, :count).by(-1)
      expect(response).to have_http_status(:ok)
    end

    it "削除してリダイレクト（通常）" do
      item = create(:template_item)
      expect {
        delete template_item_path(item)
      }.to change(TemplateItem, :count).by(-1)
      expect(response).to redirect_to(template_items_path)
    end
  end

  describe "PATCH /template_items/reorder" do
    it "sort_order を更新して 200 を返す" do
      item1 = create(:template_item, sort_order: 0)
      item2 = create(:template_item, sort_order: 1)
      patch reorder_template_items_path, params: { ids: [ item2.id, item1.id ] }
      expect(response).to have_http_status(:ok)
      expect(item1.reload.sort_order).to eq(1)
      expect(item2.reload.sort_order).to eq(0)
    end
  end
end
