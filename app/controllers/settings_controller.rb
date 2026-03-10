class SettingsController < ApplicationController
  skip_before_action :require_group_membership, only: %i[ new_group create_group join ]

  def show; end

  def update
    if @setting.update(setting_params)
      redirect_to setting_path, notice: "設定を保存しました"
    else
      render :show, status: :unprocessable_content
    end
  end

  def new_group
    @setting = Setting.new(member_a: "たろう", member_b: "はなこ")
  end

  def create_group
    @setting = Setting.new(setting_params.merge(owner_id: current_user.id))
    if @setting.save
      current_user.update!(setting: @setting)
      redirect_to setting_path, notice: "グループを作成しました！招待コードでパートナーを招待してください。"
    else
      render :new_group, status: :unprocessable_content
    end
  end

  def join
    return unless request.post?

    # 既にグループに所属している場合は拒否
    if current_user.setting.present?
      redirect_to setting_path, alert: "既にグループに参加しています"
      return
    end

    @setting = Setting.find_by(invite_code: params[:invite_code])
    unless @setting
      @error = "招待コードが見つかりません"
      render :join, status: :unprocessable_content
      return
    end

    # 参加人数上限チェック（2人まで）
    if @setting.users.count >= 2
      @error = "このグループは既に満員です（参加上限: 2人）"
      render :join, status: :unprocessable_content
      return
    end

    current_user.update!(setting: @setting)
    redirect_to root_path, notice: "グループに参加しました！"
  end

  private

  def setting_params
    params.require(:setting).permit(:member_a, :member_b)
  end
end
