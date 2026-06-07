module Api
  module V1
    # JSON API の共通基底（ADR 0012）。
    # HTML 用 ApplicationController(ActionController::Base) とは分離し、
    # API 向けの軽量基底 ActionController::API を使う。
    # 認証は既存の Cookie セッション(Authentication concern)を流用するため
    # ActionController::Cookies を include する。
    class BaseController < ActionController::API
      include ActionController::Cookies
      include Authentication

      before_action :require_group_membership

      rescue_from ActiveRecord::RecordNotFound do
        render_error(:not_found, "リソースが見つかりません")
      end

      private

      def current_setting
        Current.session&.user&.setting
      end

      # Authentication concern の HTML リダイレクトを上書きし、401 JSON を返す。
      def request_authentication
        render_error(:unauthorized, "認証が必要です")
      end

      def require_group_membership
        return if current_setting

        render_error(:forbidden, "グループに参加していません")
      end

      def render_error(status, message)
        render json: { error: { code: status.to_s, message: message } }, status: status
      end

      # バリデーション失敗を 422 + error JSON（details にメッセージ一覧）で返す。
      def render_validation_errors(record)
        render json: {
          error: {
            code:    "unprocessable_content",
            message: "保存に失敗しました",
            details: record.errors.full_messages
          }
        }, status: :unprocessable_content
      end
    end
  end
end
