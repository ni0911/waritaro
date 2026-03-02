module ApplicationHelper
  def nav_tab(label, path, icon:)
    active = current_page?(path) || request.path.start_with?(path == root_path ? "/sheets" : path)
    css = active ? "text-blue-600" : "text-gray-500"
    link_to path, class: "flex-1 flex flex-col items-center py-2 text-xs font-medium #{css}" do
      concat tag.span(icon, class: "text-xl leading-none")
      concat tag.span(label)
    end
  end
end
