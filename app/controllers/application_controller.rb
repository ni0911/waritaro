class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :require_authentication
  before_action :require_group_membership
  before_action :set_setting

  helper_method :current_setting

  private

  def current_setting
    Current.session&.user&.setting
  end

  def set_setting
    @setting = current_setting
  end

  def require_group_membership
    return unless current_user
    return if current_user.setting.present?

    allowed_paths = [
      new_session_path,
      session_path,
      new_registration_path,
      registrations_path,
      new_group_setting_path,
      join_setting_path
    ]
    redirect_to new_group_setting_path unless allowed_paths.include?(request.path)
  end

  def current_user
    Current.session&.user
  end
  helper_method :current_user
end
