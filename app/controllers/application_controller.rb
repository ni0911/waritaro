class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_authentication
  before_action :require_membership

  helper_method :current_user, :current_groups

  private

  def current_user
    Current.session&.user
  end

  # ログインユーザーが参加している全グループ（最近更新順）
  def current_groups
    return Group.none unless current_user
    current_user.groups.order(updated_at: :desc)
  end

  # まだどのグループにも参加していないユーザーをオンボーディングへ誘導する。
  def require_membership
    return unless current_user
    return if current_user.members.exists?

    allowed_paths = [
      new_session_path, session_path,
      new_registration_path, registrations_path,
      new_group_path, groups_path,
      new_membership_path, membership_path
    ]
    redirect_to new_group_path unless allowed_paths.include?(request.path)
  end

  # 指定グループに current_user がメンバーとして参加しているか検証し、@group をセット
  def set_member_group
    @group = current_user.groups.find(params[:group_id] || params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "そのグループにはアクセスできません"
  end
end
