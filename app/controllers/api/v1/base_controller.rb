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

      DEFAULT_PER_PAGE = 20
      MAX_PER_PAGE     = 100

      before_action :require_group_membership

      # 例外ハンドリングを基底に集約し、全エラーを統一 JSON で返す（ADR 0012 / フェーズ1-5）。
      rescue_from ActiveRecord::RecordNotFound do
        render_error(:not_found, "リソースが見つかりません")
      end

      rescue_from ActionController::ParameterMissing do |e|
        render_error(:bad_request, "必須パラメータがありません: #{e.param}")
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render_validation_errors(e.record)
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

      # offset / limit ページネーション（ADR 0012 / フェーズ1-6）。
      # 戻り値: [絞り込んだリレーション, メタ情報ハッシュ]
      def paginate(relation)
        page     = [ params[:page].to_i, 1 ].max
        per_page = params[:per_page].to_i
        per_page = DEFAULT_PER_PAGE if per_page <= 0
        per_page = [ per_page, MAX_PER_PAGE ].min

        total_count = relation.count
        total_pages = total_count.zero? ? 1 : (total_count.to_f / per_page).ceil
        records     = relation.limit(per_page).offset((page - 1) * per_page)

        meta = {
          page:        page,
          per_page:    per_page,
          total_count: total_count,
          total_pages: total_pages
        }
        [ records, meta ]
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
