class CardsController < ApplicationController
  before_action :set_card, only: [ :edit, :update, :destroy ]

  def index
    @cards_a = current_setting.cards.where(owner: "A").order(:name)
    @cards_b = current_setting.cards.where(owner: "B").order(:name)
  end

  def new
    @card = current_setting.cards.new
  end

  def create
    @card = current_setting.cards.new(card_params)
    if @card.save
      redirect_to cards_path, notice: "カードを追加しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @card.update(card_params)
      redirect_to cards_path, notice: "カードを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @card.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("card_#{@card.id}") }
      format.html { redirect_to cards_path, notice: "カードを削除しました" }
    end
  end

  private

  def set_card
    @card = current_setting.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:name, :owner)
  end
end
