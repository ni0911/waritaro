class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  skip_before_action :require_group_membership

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to new_group_setting_path, notice: "アカウントを作成しました。グループを設定してください。"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
