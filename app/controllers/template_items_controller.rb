class TemplateItemsController < ApplicationController
  before_action :set_item, only: [:edit, :update, :destroy]

  def index
    @template_items = TemplateItem.includes(:card).all
  end

  def new
    @template_item = TemplateItem.new(burden_a: 0, burden_b: 0)
    @cards = Card.order(:owner, :name)
  end

  def create
    @template_item = TemplateItem.new(template_item_params)
    @template_item.sort_order = TemplateItem.maximum(:sort_order).to_i + 1
    if @template_item.save
      redirect_to template_items_path, notice: "テンプレートを追加しました"
    else
      @cards = Card.order(:owner, :name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @cards = Card.order(:owner, :name)
  end

  def update
    if @template_item.update(template_item_params)
      redirect_to template_items_path, notice: "テンプレートを更新しました"
    else
      @cards = Card.order(:owner, :name)
      render :edit, status: :unprocessable_entity
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
      TemplateItem.where(id: id).update_all(sort_order: index)
    end
    head :ok
  end

  private

  def set_item
    @template_item = TemplateItem.find(params[:id])
  end

  def template_item_params
    params.require(:template_item).permit(:name, :amount, :payer, :burden_a, :burden_b, :card_id)
  end
end
