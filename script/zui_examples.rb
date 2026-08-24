# frozen_string_literal: true

# Source-backed examples for the public Zui Builder API. Every example calls the
# named Builder method directly and is executed by script/validate_zui_examples.rb.
module ZuiExamples
  module_function

  def for(slug, category)
    public_send(category_method(category), slug)
  end

  def category_method(category)
    {
      "Foundation and layout" => :layout,
      "Display, content, and media" => :content,
      "Buttons and input" => :input,
      "Navigation and structure" => :navigation,
      "Menus, dialogs, and feedback" => :feedback,
      "Data and collections" => :collection,
      "Charts and visualization" => :chart,
      "Drawing and interaction" => :drawing,
      "Animation, state, and timing" => :motion,
      "Effects" => :effect,
      "Multimedia and capture" => :multimedia,
      "Models and utilities" => :utility
    }.fetch(category, :utility)
  end

  def layout(slug)
    case slug
    when "container"
      container_example("container", "padding: 24, spacing: 12")
    when "row", "row_layout"
      <<~RUBY
        #{slug} spacing: 12, alignment: :center do
          button "Back", icon: :arrow_left
          spacer fill_width: true
          button "Continue", icon: :arrow_right
        end
      RUBY
    when "column", "column_layout"
      container_example(slug, "spacing: 12, fill_width: true")
    when "grid", "grid_layout"
      <<~RUBY
        #{slug} columns: 3, column_spacing: 12, row_spacing: 12 do
          card { label "CPU" }
          card { label "Memory" }
          card { label "Network" }
        end
      RUBY
    when "flow"
      <<~RUBY
        flow width: 520, spacing: 8, orientation: :horizontal do
          chip "Ruby", selected: true
          chip "Qt"
          chip "Native"
        end
      RUBY
    when "stack"
      <<~RUBY
        stack width: 420, height: 220 do
          rectangle color: "#18181d", radius: 18
          center { label "Layered content", bold: true }
        end
      RUBY
    when "center"
      <<~RUBY
        center width: 420, height: 240, padding: 24 do
          progress_ring 72, size: 96
        end
      RUBY
    when "card"
      container_example("card", "padding: 24, spacing: 12, accent: \"#b7ff5a\"")
    when "scroll"
      <<~RUBY
        scroll width: 420, height: 280, clip: true do
          column spacing: 10 do
            12.times { |index| label "Result \#{index + 1}" }
          end
        end
      RUBY
    when "rectangle"
      <<~RUBY
        rectangle width: 320, height: 180,
          color: "#18181d", radius: 20,
          border_color: "#b7ff5a", border_width: 1 do
          center { label "Native surface" }
        end
      RUBY
    when "border_overlay"
      <<~RUBY
        border_overlay width: 420, height: 220,
          color: "#b7ff5a", width_spec: 2,
          radius: 18
      RUBY
    when "aspect_ratio"
      <<~RUBY
        aspect_ratio ratio: 16.0 / 9, width: 640, clip: true do
          image "assets/preview.jpg", fill_mode: :preserve_aspect_crop
        end
      RUBY
    when "constrained_box"
      <<~RUBY
        constrained_box min_width: 280, max_width: 640,
          min_height: 160, max_height: 360 do
          card { text "Content stays inside the declared bounds." }
        end
      RUBY
    when "fitted_box"
      <<~RUBY
        fitted_box width: 360, height: 180,
          fit: :contain, alignment: :center do
          label "Scale me", size: 42, bold: true
        end
      RUBY
    when "wrap"
      <<~RUBY
        wrap width: 420, spacing: 8, orientation: :horizontal do
          %w[State Events Charts Media Effects].each { |name| chip name }
        end
      RUBY
    when "split_view"
      <<~RUBY
        split_view width: 760, height: 420, orientation: :horizontal do
          pane preferred_width: 220 do
            label "Navigation"
          end
          pane fill_width: true do
            label "Workspace"
          end
        end
      RUBY
    when "stack_layout"
      <<~RUBY
        stack_layout current_index: 1, width: 520, height: 280 do
          page("Overview") { text "Overview content" }
          page("Activity") { text "Activity content" }
        end
      RUBY
    when "layout_item_proxy"
      <<~RUBY
        source = card id: :summary_card, preferred_width: 320 do
          label "Build summary"
        end

        layout_item_proxy source,
          fill_width: true,
          minimum_width: 240
      RUBY
    when "loader"
      <<~RUBY
        loader active: true, asynchronous: true,
          width: 420, height: 240 do
          skeleton width: 420, height: 120
        end
      RUBY
    when "flickable"
      <<~RUBY
        flickable width: 420, height: 260,
          content_width: 840, content_height: 520,
          direction: :both, clip: true do
          image "assets/map.png", width: 840, height: 520
        end
      RUBY
    when "focus_scope"
      <<~RUBY
        focus_scope focus: true, width: 420, height: 160 do
          text_field "", placeholder: "Keyboard focus starts here"
        end
      RUBY
    when "flipable"
      <<~RUBY
        flipable flipped: false, axis: :y,
          duration: 320, width: 320, height: 200 do
          card { label "Front / back content" }
        end
      RUBY
    when "border_image"
      <<~RUBY
        border_image "assets/frame.png",
          width: 420, height: 240,
          border_left: 24, border_top: 24,
          border_right: 24, border_bottom: 24 do
          center { label "Nine-slice frame" }
        end
      RUBY
    when "window"
      <<~RUBY
        window "Inspector", width: 520, height: 360,
          minimum_width: 360, visible: true do
          column(spacing: 12) { label "Detached native window" }
        end
      RUBY
    when "application_window"
      <<~RUBY
        application_window "Zui Studio",
          width: 960, height: 680,
          minimum_width: 720 do
          column_layout(spacing: 16) { label "Application content" }
        end
      RUBY
    else
      raise "Missing layout example: #{slug}"
    end
  end

  def content(slug)
    {
      "text" => 'text "Requests: 14.2k", size: 28, bold: true, color: "#f5f5f0"',
      "icon" => 'icon :ruby, size: 28, color: "#b7ff5a"',
      "image" => 'image "assets/dashboard.png", width: 640, height: 360, fill_mode: :preserve_aspect_crop',
      "spacer" => 'spacer height: 24, fill_width: true',
      "separator" => 'separator strength: 0.35',
      "section_header" => 'section_header "Recent activity"',
      "panel_hero" => 'panel_hero "Build complete", meta: "main · 42s", detail: "All checks passed"',
      "optical_glyph" => 'optical_glyph "◆", size: 32, color: "#b7ff5a"',
      "tooltip" => 'tooltip "Open the component catalog", delay: 350, timeout: 4_000',
      "label" => 'label "Native Ruby UI", size: 22, bold: true, elide: :right',
      "rich_text" => 'rich_text "<b>Native</b> content with an <a href=\"https://ruby-lang.org\">external link</a>", width: 520',
      "selectable_text" => 'selectable_text "Copy this generated token: zui_42a9", width: 460',
      "animated_image" => 'animated_image "assets/activity.gif", width: 320, height: 180, playing: true',
      "video" => 'video "assets/intro.mp4", width: 640, height: 360, auto_play: true, loops: 2',
      "audio" => 'audio "assets/chime.ogg", auto_play: false, volume: 0.7',
      "avatar" => 'avatar "assets/ada.png", name: "Ada Lovelace", size: 48',
      "badge" => 'badge 12, maximum: 99, background: "#b7ff5a", foreground: "#101408"',
      "chip" => 'chip "Ruby", icon: :ruby, selected: true, deletable: true',
      "divider" => 'divider orientation: :horizontal, length: 420, thickness: 1, color: "#3a3a42"',
      "markdown" => <<~RUBY.chomp,
        markdown <<~MARKDOWN, width: 520, link_color: "#b7ff5a"
          ## Build status

          All **checks passed**.
        MARKDOWN
      RUBY
      "vector_image" => 'vector_image "assets/architecture.svg", width: 520, height: 300, fill_mode: :preserve_aspect_fit',
      "model_view_3d" => 'model_view_3d "assets/engine.glb", width: 520, height: 420, interactive: true, auto_rotate: true',
      "font_loader" => 'font_loader "assets/fonts/Display.woff2"',
      "text_metrics" => 'text_metrics "Native Ruby UI", font_family: "Roboto Mono", font_size: 18, bold: true'
    }.fetch(slug).then { |example| normalize(example) }
  end

  def input(slug)
    examples = {
      "button" => 'button("Deploy", icon: :play, accent: "#b7ff5a") { puts "Deploy requested" }',
      "action_button" => 'action_button(:refresh, tooltip: "Refresh data") { puts "Refresh requested" }',
      "bar_icon_button" => 'bar_icon_button(:bell, tooltip: "Notifications", active: true) { puts "Notifications opened" }',
      "bar_indicator" => 'bar_indicator :wifi, inactive_icon: :warning, active: true, active_tooltip: "Connected"',
      "widget_button" => 'widget_button("12:42", active: true, tooltip: "Open clock") { puts "Clock opened" }',
      "checkbox" => 'checkbox("Include archived", checked: false) { |checked| puts "Archived: #{checked}" }',
      "toggle" => 'toggle("Notifications", checked: true, description: "Show native alerts") { |checked| puts "Notifications: #{checked}" }',
      "toggle_switch" => 'toggle_switch checked: true, accent: "#b7ff5a" do |checked|\n  puts "Enabled: #{checked}"\nend',
      "text_field" => 'text_field("", placeholder: "Project name") { |value| puts "Project: #{value}" }',
      "number_field" => 'number_field 8, label: "Workers", from: 1, to: 32, step: 1',
      "slider" => 'slider 68, minimum: 0, maximum: 100, step: 1, ticks: true',
      "dropdown" => 'dropdown :balanced, label: "Profile", options: %i[quiet balanced performance]',
      "searchable_dropdown" => 'searchable_dropdown :ruby, label: "Language", options: %i[ruby crystal elixir], placeholder: "Search languages"',
      "multi_select" => 'multi_select %i[charts media], label: "Features", options: %i[charts media effects three_d]',
      "button_group" => 'button_group :day, options: [{ label: "Day", value: :day }, { label: "Week", value: :week }]',
      "round_button" => 'round_button "", icon: :plus, diameter: 44 do\n  puts "Item added"\nend',
      "tool_button" => 'tool_button "Save", icon: :save, checked: false do\n  puts "Document saved"\nend',
      "delay_button" => 'delay_button("Hold to delete", delay: 1_200) { puts "Delete confirmed" }',
      "radio_button" => 'radio_button("Automatic", value: :auto, checked: true) { |checked| puts "Automatic: #{checked}" }',
      "radio_group" => 'radio_group :system, options: [{ label: "System", value: :system }, { label: "Dark", value: :dark }]',
      "text_area" => 'text_area "Release notes", placeholder: "What changed?", width: 520, height: 180, maximum_length: 2_000',
      "search_field" => 'search_field("", suggestions: %w[Button Card Chart], live: true) { |query| puts "Query: #{query}" }',
      "password_field" => 'password_field "", placeholder: "Access token", revealable: true',
      "range_slider" => 'range_slider 20, 80, minimum: 0, maximum: 100, step: 5, live: true',
      "dial" => 'dial 35, minimum: 0, maximum: 100, step: 1, start_angle: -140, end_angle: 140',
      "spin_box" => 'spin_box 3, minimum: 1, maximum: 12, prefix: "× ", editable: true',
      "color_picker" => 'color_picker "#b7ff5a", label: "Accent", show_alpha: true',
      "date_picker" => 'date_picker "2026-08-24", label: "Release date", format: "yyyy-MM-dd"',
      "time_picker" => 'time_picker "14:30", label: "Deploy at", use_24_hour: true, minute_step: 5',
      "file_picker" => 'file_picker "", label: "Import data", filters: ["JSON files (*.json)", "All files (*)"]',
      "folder_picker" => 'folder_picker "", label: "Export directory", title: "Choose a folder"',
      "font_picker" => 'font_picker "Inter", label: "Interface font", point_size: 14',
      "double_spin_box" => 'double_spin_box 1.25, minimum: 0.0, maximum: 10.0, step: 0.25, decimals: 2, suffix: "×"',
      "dialog_button_box" => 'dialog_button_box %i[save cancel], alignment: :right, spacing: 8',
      "action" => 'action("Refresh", icon: :refresh, shortcut: "Ctrl+R") { puts "Refresh requested" }',
      "action_group" => <<~RUBY.chomp
        select = action "Select", checkable: true, checked: true
        move = action "Move", checkable: true

        action_group [select, move], checked: select, exclusive: true
      RUBY
    }
    normalize(examples.fetch(slug))
  end

  def navigation(slug)
    examples = {
      "list_view" => 'list_view([{ id: 1, name: "Overview", icon: :house }, { id: 2, name: "Settings", icon: :gear }], key_field: :id, label_field: :name, icon_field: :icon, selected: 1) { |item| puts "Opened: #{item.fetch("name")}" }',
      "key_catcher" => 'keys = key_catcher blocked: false do\n  label "Press an arrow key or Escape"\nend\non(keys, :move) { |event| puts event.fetch("direction") }',
      "page" => 'page "Overview", padding: 24, spacing: 16 do\n  label "Workspace overview", size: 28, bold: true\n  text "Page content"\nend',
      "pane" => 'pane padding: 20, spacing: 12, background: "#18181d", radius: 16 do\n  label "Inspector", bold: true\n  text "Pane content"\nend',
      "frame" => 'frame padding: 16, border_color: "#3a3a42", radius: 12 do\n  image "assets/preview.png", width: 320, height: 180\nend',
      "group_box" => 'group_box "Connection", padding: 18, spacing: 10 do\n  text_field "localhost", placeholder: "Host"\n  number_field 3000, label: "Port"\nend',
      "tabs" => 'tabs %w[Overview API Examples], current_index: 0 do\n  text "Overview content"\n  text "API content"\n  text "Example content"\nend',
      "tab_bar" => 'tab_bar [{ text: "Overview", icon: :house }, { text: "Activity", icon: :clock }], current_index: 0',
      "tab_button" => 'tab_button("Overview", icon: :house, checked: true) { puts "Overview selected" }',
      "page_indicator" => 'page_indicator 5, current_index: 2, interactive: true, dot_size: 8',
      "stack_view" => 'stack_view current_index: 0, animated: true, width: 520, height: 320 do\n  page("Overview") { text "First page" }\n  page("Details") { text "Second page" }\nend',
      "swipe_view" => 'swipe_view current_index: 0, orientation: :horizontal, interactive: true do\n  page("Today") { text "Today" }\n  page("Tomorrow") { text "Tomorrow" }\nend',
      "drawer" => 'drawer opened: true, edge: :left, width: 320, modal: true do\n  column(spacing: 12) { label "Navigation" }\nend',
      "navigation_rail" => 'navigation_rail [{ label: "Home", icon: :house }, { label: "Search", icon: :search }, { label: "Settings", icon: :gear }], current_index: 0, extended: true',
      "breadcrumb" => 'breadcrumb [{ label: "Projects", value: :projects }, { label: "Zui", value: :zui }, { label: "Builds", value: :builds }], current_index: 2',
      "pagination" => 'pagination 12, page: 4, sibling_count: 1, show_first_last: true',
      "expansion_panel" => 'expansion_panel "Advanced settings", expanded: true, animated: true do\n  toggle "Enable telemetry", checked: false\nend',
      "accordion" => 'accordion ["Runtime", "Rendering", "Distribution"], expanded_indices: [0], multiple: false do\n  text "Runtime details"\n  text "Rendering details"\n  text "Distribution details"\nend',
      "tool_bar" => 'tool_bar spacing: 6, position: :top do\n  tool_button "Save", icon: :save\n  tool_separator\n  tool_button "Run", icon: :play\nend',
      "tool_separator" => 'tool_separator orientation: :vertical, length: 28, thickness: 1'
    }
    normalize(examples.fetch(slug))
  end

  def feedback(slug)
    examples = {
      "confirm_dialog" => 'confirm_dialog "Delete this build?", opened: true, cancel_text: "Keep", confirm_text: "Delete"',
      "progress" => 'progress 64, minimum: 0, maximum: 100, width: 360, color: "#b7ff5a"',
      "menu" => 'menu [{ text: "New window", value: :new }, { text: "Settings", value: :settings }], opened: true',
      "menu_item" => 'menu_item("Duplicate", value: :duplicate, icon: :copy, shortcut: "Ctrl+D") { puts "Duplicate selected" }',
      "menu_separator" => 'menu_separator visible: true',
      "menu_bar" => 'menu_bar [{ title: "File", items: [{ text: "New", value: :new }, { text: "Quit", value: :quit }] }]',
      "context_menu" => 'context_menu [{ text: "Copy", value: :copy }, { text: "Delete", value: :delete }], x: 120, y: 80, opened: true',
      "popup" => 'popup opened: true, x: 40, y: 40, padding: 16 do\n  label "Quick actions"\nend',
      "dialog" => 'dialog "Create project", opened: true, width: 460 do\n  text_field "", placeholder: "Project name"\nend',
      "alert_dialog" => 'alert_dialog "Connection lost", "Check the network and try again.", opened: true, severity: :warning',
      "message_dialog" => 'message_dialog "Build complete", "All checks passed.", opened: true, buttons: %i[ok]',
      "bottom_sheet" => 'bottom_sheet opened: true, height: 280, modal: true do\n  panel_hero "Export build", detail: "Choose a destination"\nend',
      "modal_sheet" => 'modal_sheet "Command palette", opened: true, width: 620 do\n  search_field "", suggestions: %w[Build Deploy Settings], live: true\nend',
      "snackbar" => 'snackbar "Draft saved", opened: true, action_text: "Undo", duration: 4_000',
      "banner" => 'banner "A new Zui version is available.", severity: :info, action_text: "View release"',
      "toast" => 'toast "Deployment started", opened: true, severity: :success, duration: 3_000',
      "busy_indicator" => 'busy_indicator true, width: 32, height: 32, color: "#b7ff5a"',
      "progress_ring" => 'progress_ring 72, minimum: 0, maximum: 100, size: 92, thickness: 8',
      "skeleton" => 'skeleton width: 420, height: 96, radius: 14, animated: true'
    }
    normalize(examples.fetch(slug))
  end

  def collection(slug)
    examples = {
      "item_delegate" => 'item_delegate("Build #184", value: 184, description: "Passed · 42s", icon: :circle_check) { |value| puts "Build: #{value}" }',
      "check_delegate" => 'check_delegate "Run tests", value: :tests, checked: true, description: "Required before deploy"',
      "radio_delegate" => 'radio_delegate "Production", value: :production, checked: true, description: "Deploy to customers"',
      "switch_delegate" => 'switch_delegate "Auto deploy", value: :auto_deploy, checked: false, description: "Deploy when checks pass"',
      "swipe_delegate" => 'swipe_delegate "Release notes", value: 42, left_action: "Archive", right_action: "Delete"',
      "grid_view" => 'grid_view([{ id: 1, name: "Documents", icon: :folder }, { id: 2, name: "Images", icon: :image }], key_field: :id, label_field: :name, icon_field: :icon, cell_width: 180, cell_height: 120)',
      "table_view" => <<~RUBY.chomp,
        rows = [
          { name: "Ada", role: "Engineer", status: "Online" },
          { name: "Grace", role: "Scientist", status: "Away" }
        ]
        columns = [
          { key: :name, label: "Name", width: 180 },
          { key: :role, label: "Role", width: 220 },
          { key: :status, label: "Status", width: 120 }
        ]

        table = table_view rows, columns: columns,
          selection_behavior: :rows,
          alternating_rows: true

        on table, :cell_click do |cell|
          puts "Selected row: \#{cell.fetch("row")}"
        end
      RUBY
      "tree_view" => <<~RUBY.chomp,
        rows = [{
          name: "src", kind: "folder", children: [
            { name: "app.rb", kind: "file", children: [] }
          ]
        }]

        tree_view rows,
          columns: [{ key: :name, label: "Name", width: 280 },
                    { key: :kind, label: "Kind", width: 110 }],
          children_field: :children,
          expanded_paths: [[0]]
      RUBY
      "data_table" => 'data_table([{ service: "API", latency: 42, status: "Healthy" }, { service: "Queue", latency: 18, status: "Healthy" }], columns: [{ key: :service, label: "Service" }, { key: :latency, label: "Latency (ms)" }, { key: :status, label: "Status" }], sort_column: 1, sort_order: :ascending)',
      "horizontal_header" => 'horizontal_header ["Name", "Status", "Updated"], section_width: 180, clickable: true',
      "vertical_header" => 'vertical_header ["A", "B", "C"], section_height: 42',
      "table_view_delegate" => 'table_view_delegate "Ada Lovelace", row: 0, column: 0, selected: true',
      "tree_view_delegate" => 'tree_view_delegate "components", depth: 1, expanded: true, has_children: true',
      "horizontal_header_delegate" => 'horizontal_header_delegate "Status", index: 1, sort_order: :ascending',
      "vertical_header_delegate" => 'vertical_header_delegate "3", index: 2, selected: false',
      "reorderable_list" => 'reorderable_list [{ id: 1, label: "Design" }, { id: 2, label: "Build" }, { id: 3, label: "Ship" }], key_field: :id, label_field: :label',
      "carousel" => 'carousel [{ title: "Ruby", image: "assets/ruby.png" }, { title: "Qt", image: "assets/qt.png" }], label_field: :title, image_field: :image, current_index: 0',
      "calendar" => 'calendar "2026-08-24", show_week_numbers: true, show_navigation: true, width: 520',
      "month_grid" => 'month_grid month: 7, year: 2026, selected_date: "2026-08-24", width: 420',
      "week_number_column" => 'week_number_column month: 7, year: 2026, width: 48',
      "day_of_week_row" => 'day_of_week_row locale: "en_US", width: 420',
      "tumbler" => 'tumbler %w[Low Medium High], current_index: 1, visible_item_count: 3, wrap: true'
    }
    normalize(examples.fetch(slug))
  end

  def chart(slug)
    examples = {
      "line_chart" => 'line_chart [18, 42, 31, 76, 58, 91], labels: %w[Mon Tue Wed Thu Fri Sat], color: "#b7ff5a", show_points: true',
      "area_chart" => 'area_chart [12, 28, 24, 51, 46, 72], labels: %w[Jan Feb Mar Apr May Jun], color: "#66e3ff", fill_color: "#66e3ff33"',
      "bar_chart" => 'bar_chart [42, 67, 51, 88], labels: %w[North South East West], colors: %w[#b7ff5a #66e3ff #a88bff #ffb45b]',
      "stacked_bar_chart" => 'stacked_bar_chart [[18, 24, 31], [12, 19, 26]], labels: %w[Mon Tue Wed], series: [{ name: "Web", values: [18, 24, 31] }, { name: "API", values: [12, 19, 26] }], legend: true',
      "pie_chart" => 'pie_chart [46, 31, 23], labels: %w[Ruby QML Native], colors: %w[#b7ff5a #a88bff #66e3ff], show_labels: true',
      "donut_chart" => 'donut_chart [68, 22, 10], labels: %w[Complete Running Queued], center_text: "68%", inner_radius: 0.62',
      "scatter_chart" => 'scatter_chart [{ x: 1, y: 18 }, { x: 2, y: 31 }, { x: 3, y: 27 }, { x: 4, y: 52 }], point_size: 6, connect_lines: true',
      "bubble_chart" => 'bubble_chart [{ x: 1, y: 28, size: 12, label: "Ruby" }, { x: 3, y: 46, size: 24, label: "Qt" }, { x: 5, y: 34, size: 18, label: "QML" }]',
      "radar_chart" => 'radar_chart [[82, 94, 76, 88, 91]], labels: %w[Speed Memory UX Media GPU], levels: 5, point_size: 4',
      "heatmap" => 'heatmap [[12, 24, 36], [28, 52, 41], [18, 33, 64]], x_labels: %w[Mon Tue Wed], y_labels: %w[API Web Jobs], show_values: true',
      "sparkline" => 'sparkline [12, 19, 15, 28, 23, 37, 34], width: 180, height: 48, color: "#b7ff5a", show_points: true',
      "gauge" => 'gauge [72], value: 72, minimum: 0, maximum: 100, label: "CPU", show_label: true',
      "radial_gauge" => 'radial_gauge [84], value: 84, minimum: 0, maximum: 100, start_angle: -135, end_angle: 135, label: "Score"',
      "histogram" => 'histogram [12, 18, 19, 21, 24, 24, 27, 31, 35, 42], bins: 6, color: "#a88bff", show_grid: true',
      "candlestick_chart" => 'candlestick_chart [{ open: 42, high: 51, low: 39, close: 48 }, { open: 48, high: 56, low: 44, close: 46 }, { open: 46, high: 62, low: 45, close: 59 }], labels: %w[Mon Tue Wed]',
      "legend" => 'legend [{ label: "Ruby", color: "#b7ff5a" }, { label: "Qt", color: "#66e3ff" }, { label: "QML", color: "#a88bff" }], orientation: :horizontal, interactive: true'
    }
    normalize(examples.fetch(slug))
  end

  def drawing(slug)
    examples = {
      "canvas" => 'canvas [{ op: :fill_rect, x: 20, y: 20, width: 180, height: 90, color: "#b7ff5a" }, { op: :text, x: 36, y: 70, text: "Native canvas", color: "#101408", size: 18 }], width: 420, height: 220, antialiasing: true',
      "shape" => 'shape "M 20 120 C 90 20, 180 20, 250 120", width: 280, height: 150, stroke: "#b7ff5a", stroke_width: 4, fill: "transparent"',
      "line" => 'line 20, 80, 300, 80, stroke: "#66e3ff", stroke_width: 3, dash_pattern: [8, 4]',
      "path" => 'path "M 20 120 C 90 20, 180 20, 250 120", width: 280, height: 150, stroke: "#b7ff5a", fill: "transparent", stroke_width: 3',
      "circle" => 'circle 64, center_x: 80, center_y: 80, width: 160, height: 160, stroke: "#b7ff5a", fill: "#b7ff5a22", stroke_width: 3',
      "gradient" => 'gradient %w[#b7ff5a #66e3ff #a88bff], stops: [0.0, 0.55, 1.0], type: :linear, width: 420, height: 180, angle: 20, radius: 18',
      "shader_effect" => 'shader_effect "assets/shaders/plasma.frag.qsb", width: 640, height: 360, running: true, intensity: 0.85',
      "shader_effect_source" => 'shader_effect_source width: 420, height: 240, live: true, recursive: false do\n  image "assets/source.png", width: 420, height: 240\nend',
      "particle_system" => 'particle_system width: 640, height: 360, running: true, emit_rate: 90, life_span: 1_800, size: 9, end_size: 1, color: "#b7ff5a", gravity: 24',
      "drag_area" => 'drag_area axis: :both, minimum_x: 0, maximum_x: 360, minimum_y: 0, maximum_y: 200, width: 420, height: 260 do\n  card(width: 80, height: 80) { icon :move }
end',
      "drop_area" => 'drop_area keys: %w[files images], width: 420, height: 220 do\n  center { label "Drop files here" }
end',
      "pinch_area" => 'pinch_area minimum_scale: 0.5, maximum_scale: 4.0, width: 520, height: 360 do\n  image "assets/map.png", width: 520, height: 360\nend',
      "hover_area" => 'hover_area cursor: :pointing_hand, width: 320, height: 120 do\n  card { label "Hover for details" }
end',
      "selection_rectangle" => 'table = table_view [{ name: "Ada" }, { name: "Grace" }], columns: [{ key: :name, label: "Name" }], selection_mode: :extended\nselection_rectangle table, mode: :drag',
      "scroll_bar" => 'list = list_view (1..50).map { |index| { label: "Item \#{index}" } }, height: 280\nscroll_bar list, orientation: :vertical, policy: :always_on',
      "scroll_indicator" => 'list = list_view (1..50).map { |index| { label: "Item \#{index}" } }, height: 280\nscroll_indicator list, orientation: :vertical'
    }
    normalize(examples.fetch(slug))
  end

  def motion(slug)
    examples = {
      "animation" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nanimation target: tile, property: :opacity, from: 0.2, to: 1.0, duration: 320, running: true',
      "number_animation" => target_animation("number_animation", "property: :opacity, from: 0.0, to: 1.0"),
      "color_animation" => target_animation("color_animation", 'property: :color, from: "#66e3ff", to: "#b7ff5a"'),
      "rotation_animation" => target_animation("rotation_animation", "property: :rotation, from: 0, to: 360, direction: :clockwise"),
      "vector_animation" => target_animation("vector_animation", "property: :scale3d, from: [0.8, 0.8, 0.8], to: [1.0, 1.0, 1.0]"),
      "path_animation" => <<~RUBY.chomp,
        dot = circle 10, fill: "#b7ff5a", width: 20, height: 20

        motion = path_animation dot,
          path: "M 20 120 C 120 10, 240 230, 360 120",
          orientation: :right_first,
          duration: 1_800,
          running: true

        on motion, :finish do
          puts "Path animation finished"
        end
      RUBY
      "property_animation" => target_animation("property_animation", "property: :scale, from: 0.85, to: 1.0"),
      "pause_animation" => 'pause_animation 450, running: true',
      "script_action" => 'script_action :mark_ready, trigger: true, revision: 1',
      "property_action" => 'tile = rectangle width: 120, height: 80, opacity: 0.4\nproperty_action tile, property: :opacity, value: 1.0, revision: 1',
      "parallel_animation" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nparallel_animation [{ type: :number, target: tile, property: :scale, from: 0.8, to: 1.0, duration: 280 }, { type: :number, target: tile, property: :opacity, from: 0.2, to: 1.0, duration: 280 }], running: true',
      "sequential_animation" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nsequential_animation [{ type: :number, target: tile, property: :x, from: 0, to: 180, duration: 320 }, { type: :pause, duration: 120 }, { type: :number, target: tile, property: :x, from: 180, to: 0, duration: 320 }], running: true',
      "spring_animation" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nspring_animation tile, property: :scale, from: 0.7, to: 1.0, spring: 3.0, damping: 0.25, running: true',
      "smoothed_animation" => target_animation("smoothed_animation", "property: :x, from: 0, to: 320, velocity: 180"),
      "anchor_animation" => target_animation("anchor_animation", "duration: 280, easing: :out_cubic"),
      "parent_animation" => 'pane id: :left, width: 220, height: 180\npane id: :right, width: 220, height: 180\ntile = rectangle width: 60, height: 60, color: "#b7ff5a"\nparent_animation tile, new_parent: :right, via: :left, duration: 360, running: true',
      "opacity_animator" => target_animation("opacity_animator", "from: 0.0, to: 1.0"),
      "rotation_animator" => target_animation("rotation_animator", "from: 0, to: 360"),
      "scale_animator" => target_animation("scale_animator", "from: 0.8, to: 1.0"),
      "x_animator" => target_animation("x_animator", "from: 0, to: 240"),
      "y_animator" => target_animation("y_animator", "from: 0, to: 160"),
      "uniform_animator" => 'effect = shader_effect "assets/shaders/reveal.frag.qsb", width: 420, height: 240\nuniform_animator effect, uniform: :progress, from: 0.0, to: 1.0, duration: 600, running: true',
      "frame_animation" => 'frames = frame_animation running: true\non frames, :frame do |event|\n  puts "Elapsed: #{event.fetch("elapsed")}"\nend',
      "animation_controller" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nanimation_controller tile, property: :x, from: 0, to: 280, duration: 900, progress: 0.45',
      "behavior" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\nbehavior tile, property: :opacity, value: 1.0, duration: 240, easing: :in_out_quad',
      "transition" => 'tile = rectangle width: 80, height: 80, color: "#b7ff5a"\ntransition tile, from_state: :idle, to_state: :active, animations: [{ type: :number, property: :scale, from: 0.9, to: 1.0, duration: 240 }], running: true',
      "state" => 'tile = rectangle width: 120, height: 80, color: "#3a3a42"\nstate :active, target: tile, properties: { color: "#b7ff5a", scale: 1.05 }, revision: 1',
      "state_group" => 'tile = rectangle width: 120, height: 80, color: "#3a3a42"\nstate_group tile, current: :active, states: [{ name: :idle, properties: { opacity: 0.5 } }, { name: :active, properties: { opacity: 1.0, scale: 1.05 } }], revision: 1',
      "property_changes" => 'tile = rectangle width: 120, height: 80, color: "#3a3a42"\nproperty_changes tile, properties: { opacity: 1.0, scale: 1.08 }, revision: 1',
      "anchor_changes" => 'rectangle id: :frame, width: 420, height: 220\ntile = rectangle width: 80, height: 80, color: "#b7ff5a"\nanchor_changes tile, anchors: { horizontal_center: :frame, vertical_center: :frame }, margins: {}, revision: 1',
      "parent_change" => 'pane id: :destination, width: 320, height: 200\ntile = rectangle width: 80, height: 80, color: "#b7ff5a"\nparent_change tile, parent: :destination, x: 24, y: 24, revision: 1',
      "timer" => 'clock = timer 1_000, repeat: true, running: true\non clock, :trigger do\n  puts "Timer triggered"\nend'
    }
    normalize(examples.fetch(slug))
  end

  def effect(slug)
    examples = {
      "multi_effect" => 'multi_effect brightness: 0.05, saturation: 1.15, blur_enabled: true, blur: 0.25, shadow_enabled: true, shadow_opacity: 0.35 do\n  image "assets/product.png", width: 420, height: 280\nend',
      "rectangular_shadow" => 'rectangular_shadow width: 360, height: 200, blur: 28, spread: 2, radius: 22, offset_y: 12, color: "#00000088" do\n  card { label "Elevated card" }\nend',
      "opacity_mask" => 'opacity_mask width: 320, height: 320, mask_source: "assets/circle-mask.png", inverted: false do\n  image "assets/portrait.jpg", width: 320, height: 320\nend',
      "blur" => 'blur width: 420, height: 260, amount: 0.55, maximum: 48 do\n  image "assets/background.jpg", width: 420, height: 260\nend',
      "drop_shadow" => 'drop_shadow width: 360, height: 200, blur: 0.7, horizontal_offset: 0, vertical_offset: 12, color: "#00000099" do\n  card { label "Shadow source" }\nend',
      "colorize" => 'colorize width: 320, height: 220, amount: 0.8, color: "#b7ff5a", saturation: 0.9 do\n  image "assets/icon.png", width: 220, height: 220\nend',
      "glow" => 'glow width: 320, height: 180, blur: 0.65, color: "#b7ff5a", opacity: 0.85 do\n  label "Signal locked", size: 34, bold: true\nend'
    }
    normalize(examples.fetch(slug))
  end

  def multimedia(slug)
    examples = {
      "media_player" => 'player = media_player "assets/sequence.mp4", auto_play: true, loops: 1, volume: 0.8',
      "video_output" => 'player = media_player "assets/sequence.mp4", auto_play: true\nvideo_output player, width: 640, height: 360, fill_mode: :preserve_aspect_crop',
      "sound_effect" => 'sound_effect "assets/complete.ogg", volume: 0.7, playback: :play, command_revision: 1',
      "camera" => 'camera active: true, focus_mode: :auto, exposure_mode: :auto, zoom_factor: 1.0',
      "capture_session" => 'capture_session camera_active: true, video_output_enabled: true, width: 640, height: 360 do\n  video_output width: 640, height: 360\nend',
      "image_capture" => 'session = capture_session camera_active: true\nimage_capture session, quality: :high, format: :jpeg, command: :capture, path: "captures/photo.jpg", command_revision: 1',
      "media_recorder" => 'session = capture_session camera_active: true\nmedia_recorder session, output_location: "captures/demo.mp4", quality: :high, resolution: [1920, 1080], command: :record, command_revision: 1',
      "audio_input" => 'audio_input device: :default, muted: false, volume: 0.85',
      "audio_output" => 'audio_output device: :default, muted: false, volume: 0.7',
      "media_devices" => 'media_devices kind: :all, refresh_revision: 1',
      "screen_capture" => 'screen_capture active: true, screen: 0, command: :start, command_revision: 1',
      "window_capture" => 'window_capture active: true, window: "app.main", command: :start, command_revision: 1'
    }
    normalize(examples.fetch(slug))
  end

  def utility(slug)
    examples = {
      "list_model" => 'list_model [{ id: 1, name: "Ruby" }, { id: 2, name: "Qt" }], revision: 1',
      "delegate_model" => 'delegate_model [{ id: 1, name: "Inbox", group: :active }, { id: 2, name: "Archive", group: :done }], filter_group: :active, revision: 1',
      "delegate_model_group" => 'delegate_model_group [{ id: 1, selected: true }, { id: 2, selected: false }], name: :selected, include_by_default: false, revision: 1',
      "sort_filter_proxy_model" => 'sort_filter_proxy_model [{ name: "Ruby", score: 98 }, { name: "Qt", score: 94 }], filter: "ru", filter_field: :name, sort_field: :score, sort_order: :descending',
      "folder_list_model" => 'folder_list_model "file:///home/user/Documents", name_filters: ["*.rb", "*.md"], show_files: true, show_dirs: true, sort_field: :name',
      "settings" => 'settings({ theme: "dark", density: "comfortable" }, category: "appearance", file_name: "zui.conf", sync_revision: 1)',
      "standard_paths" => 'standard_paths :documents, locate_file: "reports/latest.pdf", refresh_revision: 1',
      "clipboard" => 'clipboard "Copied from Zui", watch: true, revision: 1',
      "cursor_surface" => 'cursor_surface cursor: 1, current: 0, outline: true, bordered: true, foreground: "#f5f5f0", accent: "#b7ff5a" do\n  label "Keyboard-controlled surface"\nend'
    }
    normalize(examples.fetch(slug))
  end

  def container_example(name, options)
    <<~RUBY
      #{name} #{options} do
        label "System status", bold: true
        text "All services are healthy."
      end
    RUBY
  end

  def target_animation(name, options)
    <<~RUBY.chomp
      tile = rectangle width: 80, height: 80, color: "#b7ff5a"
      #{name} tile, #{options}, duration: 320, running: true
    RUBY
  end

  # Compact entries above use literal newline markers to keep the source map
  # readable. Publish them as executable multi-line Ruby examples.
  def normalize(example)
    "#{example.gsub('\\n', "\n")}\n"
  end
end
