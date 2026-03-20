module ApplicationHelper
  def nav_tab(label, path, icon:)
    active = current_page?(path) || request.path.start_with?(path == root_path ? "/sheets" : path)
    css = active ? "wt-nav-tab active" : "wt-nav-tab"
    link_to path, class: css do
      concat tag.span(icon, class: "wt-nav-icon")
      concat tag.span(label)
    end
  end
end
