class MembershipsController < ApplicationController
  skip_before_action :require_membership, only: %i[ new create ]

  def new
    @code = params[:code]
  end

  def create
    code = params[:invite_code].to_s.strip
    group = Group.find_by(invite_code: code)

    unless group
      @error = "招待コードが見つかりません"
      render :new, status: :unprocessable_content
      return
    end

    if group.member_for(current_user)
      redirect_to group_path(group), notice: "すでに参加しています"
      return
    end

    # 空きメンバー（user 未紐付け）があれば claim、なければ新規メンバー作成
    member = group.members.where(user_id: nil).where.not(name: "共同口座").order(:sort_order).first
    if member
      member.update!(user: current_user)
    else
      group.members.create!(
        name: current_user.display_name,
        color: Member::COLORS[group.members.count % Member::COLORS.size],
        user: current_user,
        sort_order: group.members.maximum(:sort_order).to_i + 1
      )
    end

    redirect_to group_path(group), notice: "「#{group.name}」に参加しました！"
  end
end
