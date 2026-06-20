module Groups
  class SettlementsController < ApplicationController
    before_action :set_member_group

    # 現在の未精算費用をスナップショット化して「精算済み」にする。
    def create
      open = @group.open_expenses
      if open.empty?
        redirect_to group_path(@group), alert: "精算する記録がありません"
        return
      end

      ActiveRecord::Base.transaction do
        settlement = @group.settlements.create!(settled_at: Time.current)
        open.update_all(settlement_id: settlement.id)
      end
      redirect_to group_path(@group), notice: "精算しました！おつかれさま 🎉"
    end
  end
end
