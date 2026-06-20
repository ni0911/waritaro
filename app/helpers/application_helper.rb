module ApplicationHelper
  # confirm_modal を使った確認つきアクションボタン（window.confirm 禁止のため）。
  # 可視トリガー + 同梱の非表示フォームを返す。トリガーが確認後にフォームを requestSubmit する。
  def confirm_action_button(label, url, message:, method: :delete, button_class: "wt-pill wt-pill-mute", style: nil)
    form_id = "cf-#{SecureRandom.hex(4)}"
    trigger = button_tag(label, type: "button", class: button_class, style: style,
      data: { action: "click->confirm-modal#open", confirm_modal_message_param: message, confirm_modal_form_param: form_id })
    hidden_form = button_to(url, method: method, form: { id: form_id, class: "hidden" }) { "" }
    safe_join([ trigger, hidden_form ])
  end

  def greeting(now = Time.current)
    h = now.hour
    return "おはよう" if h < 11
    return "こんにちは" if h < 18
    "こんばんは"
  end

  # ¥1,800（整数円・カンマ区切り）
  def yen(amount)
    "¥#{number_with_delimiter(amount.to_i)}"
  end

  # 符号付き金額。負号は en-dash（U+2212）を使う。
  def signed_yen(amount)
    n = amount.to_i
    sign = n.positive? ? "+" : (n.negative? ? "−" : "")
    "#{sign}#{yen(n.abs)}"
  end

  def balance_class(amount)
    n = amount.to_i
    return "wt-balance-pos" if n.positive?
    return "wt-balance-neg" if n.negative?
    "wt-balance-zero"
  end

  # メンバーアバター（頭文字 + メンバー固有色）
  def member_avatar(member, size: 36)
    avatar_chip(member.name, member.color, size: size)
  end

  def avatar_chip(name, color, size: 36)
    tag.span(name.to_s.first,
      class: "wt-avatar",
      style: "width:#{size}px;height:#{size}px;background:#{color};font-size:#{(size * 0.42).round}px;")
  end

  # 重なりアバタースタック（最大 max 件 + "+N"）
  def member_stack(members, max: 5, size: 24)
    shown = members.first(max)
    safe_join([
      tag.span(class: "wt-stack") do
        safe_join(shown.map { |m| tag.span(m.name.to_s.first, class: "wt-avatar wt-avatar-ring", style: "width:#{size}px;height:#{size}px;background:#{m.color};font-size:#{(size * 0.42).round}px;") })
      end,
      (members.size > max ? tag.span("+#{members.size - max}", class: "wt-stack-more") : "".html_safe)
    ])
  end
end
