class HomeController < ApplicationController
  def index
    @groups = current_groups.includes(:members).to_a
    @plans  = @groups.to_h { |g| [ g.id, SettlementService.new(g).plan ] }
    @me_member = @groups.to_h { |g| [ g.id, g.member_for(current_user) ] }

    @open_groups    = @groups.reject { |g| @plans[g.id].transfers.empty? }
    @settled_groups = @groups.select { |g| @plans[g.id].transfers.empty? }

    @me_name = current_user.display_name

    # カレンダー: 表示月の費用を日付ごとに
    @view_date     = parse_view_month
    @events_by_day = events_for_month(@view_date)
    @selected      = parse_selected_day
  end

  private

  def parse_view_month
    if params[:month].to_s.match?(/\A\d{4}-\d{2}\z/)
      Date.parse("#{params[:month]}-01")
    else
      Date.current.beginning_of_month
    end
  end

  def parse_selected_day
    return Date.parse(params[:day]) if params[:day].to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
    Date.current if Date.current.beginning_of_month == @view_date
  rescue ArgumentError
    nil
  end

  # { Date => [Expense, ...] }
  def events_for_month(view_date)
    range = view_date.beginning_of_month..view_date.end_of_month
    Expense.where(group_id: @groups.map(&:id), expense_date: range)
           .includes(:group, :payer)
           .order(expense_date: :desc, id: :desc)
           .group_by(&:expense_date)
  end
end
