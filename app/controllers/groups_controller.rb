class GroupsController < ApplicationController
  skip_before_action :require_membership, only: %i[ new create ]
  before_action :set_member_group, only: %i[ show invite share ]

  ICONS = %w[🏝️ ✈️ ⛷️ 🚗 🏠 🛒 🍻 🍽️ ☕ 🍱 🎉 🎁 🎂 🎵 🏕️].freeze

  def new
    @group = Group.new(icon: "🏝️", tile: Group::TILES.first)
    @member_names = [ current_user.display_name, "" ]
  end

  def create
    @group = Group.new(group_params)
    @member_names = Array(params[:members]).map { |n| n.to_s.strip }
    names = @member_names.reject(&:blank?)
    names = [ current_user.display_name ] if names.empty?

    ActiveRecord::Base.transaction do
      @group.owner = current_user
      @group.save!
      names.each_with_index do |name, i|
        @group.members.create!(
          name: name,
          color: Member::COLORS[i % Member::COLORS.size],
          user_id: (i.zero? ? current_user.id : nil),
          sort_order: i
        )
      end
    end
    redirect_to group_path(@group, fresh: 1), notice: "「#{@group.name}」をつくりました！"
  rescue ActiveRecord::RecordInvalid
    @member_names = names.size < 2 ? names + [ "" ] : names
    render :new, status: :unprocessable_content
  end

  def show
    @plan    = SettlementService.new(@group).plan
    @members = @group.members.to_a
    @me      = @group.member_for(current_user)
    @recent  = @group.open_expenses.includes(:payer).order(expense_date: :desc, id: :desc).limit(10)
    @fresh   = params[:fresh].present?
  end

  def invite; end

  def share
    @text = ShareTextService.new(@group).group_settlement
  end

  private

  def group_params
    params.require(:group).permit(:name, :icon, :tile)
  end
end
