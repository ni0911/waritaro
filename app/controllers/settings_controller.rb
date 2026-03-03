class SettingsController < ApplicationController
  def show; end

  def update
    if @setting.update(setting_params)
      redirect_to setting_path, notice: "設定を保存しました"
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:member_a, :member_b)
  end
end
