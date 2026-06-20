module Groups
  class ExpensesController < ApplicationController
    before_action :set_member_group

    QUICK_TITLES = [ "🍽 ごはん", "🚕 タクシー", "🏨 宿", "🛒 買い物", "🍻 のみもの", "🎟 チケット" ].freeze

    def new
      @members = @group.members.to_a
      @me = @group.member_for(current_user)
      @payer = @me || @members.first
    end

    def create
      amount = params[:amount].to_i
      title  = params[:title].to_s.strip
      payer  = @group.members.find_by(id: params[:payer_id]) || @group.member_for(current_user)
      participant_ids = Array(params[:participant_ids]).map(&:to_i)
      participants = @group.members.where(id: participant_ids).to_a
      participants = @group.members.to_a if participants.empty?

      split_mode, shares = build_split(amount, participants, params[:split_mode], params[:shares])

      @expense = @group.expenses.new(
        title: title.presence || "割り勘",
        amount: amount,
        payer: payer,
        expense_date: parse_date(params[:expense_date]),
        split_mode: split_mode
      )
      shares.each { |member_id, amt| @expense.shares.build(member_id: member_id, amount: amt) }

      if @expense.save
        @group.touch
        redirect_to group_path(@group), notice: "記録しました！"
      else
        @members = @group.members.to_a
        @me = @group.member_for(current_user)
        @payer = payer
        flash.now[:alert] = @expense.errors.full_messages.first
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      expense = @group.expenses.find_by(id: params[:id])
      if expense.nil?
        redirect_to group_path(@group), alert: "記録が見つかりません"
      elsif expense.settlement_id.present?
        # 精算済み費用は Settlement スナップショットの一部。削除すると過去の精算結果が変わるため不可。
        redirect_to group_path(@group), alert: "精算済みの記録は削除できません"
      else
        expense.destroy
        redirect_to group_path(@group), notice: "削除しました"
      end
    end

    private

    # [split_mode, { member_id => amount }] を返す。合計は必ず amount に一致させる。
    # UI は equal / custom を送るが、custom は正規の split_mode "itemized" として保存する。
    def build_split(amount, participants, mode, custom)
      return [ "equal", {} ] if participants.empty? || amount <= 0

      if mode == "custom" && custom.present?
        [ "itemized", participants.to_h { |m| [ m.id, custom[m.id.to_s].to_i ] } ]
      else
        [ "equal", equal_split(amount, participants) ]
      end
    end

    # 均等割り。端数は先頭の参加者から 1 円ずつ上乗せして合計を一致させる。
    def equal_split(amount, participants)
      n = participants.size
      base = amount / n
      rem  = amount % n
      participants.each_with_index.to_h do |m, i|
        [ m.id, base + (i < rem ? 1 : 0) ]
      end
    end

    def parse_date(value)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      Date.current
    end
  end
end
