module ApplicationHelper
  def page_title(value)
    content_for(:title, "#{value} — Zui")
  end

  def active_nav?(path)
    request.path == path || (path != root_path && request.path.start_with?(path))
  end

  def component_title(slug)
    slug.to_s.split("_").map(&:capitalize).join(" ")
  end

  def component_visual_type(component)
    {
      "Foundation and layout" => "layout", "Display, content, and media" => "content",
      "Buttons and input" => "input", "Navigation and structure" => "navigation",
      "Menus, dialogs, and feedback" => "feedback", "Data and collections" => "collection",
      "Charts and visualization" => "chart", "Drawing and interaction" => "effect",
      "Animation, state, and timing" => "motion", "Effects" => "effect",
      "Multimedia and capture" => "media", "Models and utilities" => "utility"
    }.fetch(component.fetch("category"))
  end

  def component_icon(component)
    {
      "Foundation and layout" => "⌗", "Display, content, and media" => "◫",
      "Buttons and input" => "⌁", "Navigation and structure" => "↳",
      "Menus, dialogs, and feedback" => "◉", "Data and collections" => "▦",
      "Charts and visualization" => "⌁", "Drawing and interaction" => "✦",
      "Animation, state, and timing" => "◌", "Effects" => "✺",
      "Multimedia and capture" => "▶", "Models and utilities" => "◇"
    }.fetch(component.fetch("category"))
  end
end
