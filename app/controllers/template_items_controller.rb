class TemplateItemsController < ApplicationController
  before_action :set_item, only: [ :edit, :update, :destroy ]

  def index
    @template_items = current_setting.template_items.includes(:card)
  end

  def new
    @template_item = current_setting.template_items.new(burden_a: 0, burden_b: 0)
    @cards = current_setting.cards.order(:owner, :name)
  end

  def create
    @template_item = current_setting.template_items.new(template_item_params)
    @template_item.sort_order = current_setting.template_items.maximum(:sort_order).to_i + 1
    if @template_item.save
      redirect_to template_items_path, notice: "テンプレートを追加しました"
    else
      @cards = current_setting.cards.order(:owner, :name)
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @cards = current_setting.cards.order(:owner, :name)
  end

  def update
    if @template_item.update(template_item_params)
      redirect_to template_items_path, notice: "テンプレートを更新しました"
    else
      @cards = current_setting.cards.order(:owner, :name)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @template_item.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("template_item_#{@template_item.id}") }
      format.html { redirect_to template_items_path, notice: "テンプレートを削除しました" }
    end
  end

  def reorder
    ids = params[:ids].map(&:to_i)
    ids.each_with_index do |id, index|
      current_setting.template_items.where(id: id).update_all(sort_order: index)
    end
    head :ok
  end

  private

  def set_item
    @template_item = current_setting.template_items.find(params[:id])
  end

  def template_item_params
    params.require(:template_item).permit(:name, :amount, :burden_a, :burden_b, :card_id)
  end
end
