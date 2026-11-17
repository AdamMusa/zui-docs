#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "open3"
require "pathname"
require "time"
require_relative "zui_examples"

APP_ROOT = Pathname.new(__dir__).join("..").expand_path
SOURCE_ROOT = Pathname.new(ARGV.fetch(0, ENV.fetch("ZUI_SOURCE", APP_ROOT.join("../zui").to_s))).expand_path
OUTPUT_PATH = APP_ROOT.join("config/zui_catalog.json")

abort "Zui source not found at #{SOURCE_ROOT}" unless SOURCE_ROOT.join("lib/zui.rb").file?

$LOAD_PATH.unshift(SOURCE_ROOT.join("lib").to_s)
require "zui"

CATEGORY_DESCRIPTIONS = {
  "Foundation and layout" => "Compose responsive native surfaces with predictable sizing, spacing, alignment, and containment.",
  "Display, content, and media" => "Present typography, images, video, icons, metrics, and rich visual content through native Qt renderers.",
  "Buttons and input" => "Collect intent and input with keyboard-ready controls, pickers, toggles, and focused actions.",
  "Navigation and structure" => "Shape application hierarchy with pages, tabs, rails, drawers, and progressive disclosure.",
  "Menus, dialogs, and feedback" => "Guide decisions and surface status through menus, modal surfaces, progress, and transient feedback.",
  "Data and collections" => "Render and navigate lists, grids, tables, trees, calendars, and reusable delegates.",
  "Charts and visualization" => "Turn numeric data into native charts, gauges, heatmaps, legends, and compact signals.",
  "QtCharts primitives" => "Compose a chart the way QtCharts composes one, from its own views, series, axes, sets and model mappers.",
  "QtGraphs primitives" => "Build 2D graphs and GPU-rendered 3D bar, scatter and surface graphs with QtGraphs, Qt's replacement for QtDataVisualization.",
  "Drawing and interaction" => "Draw custom scenes and capture pointer, drag, pinch, hover, and selection gestures.",
  "Animation, state, and timing" => "Coordinate motion, transitions, state changes, easing, and scheduled work in the native scene graph.",
  "Effects" => "Add GPU-backed blur, masks, glow, shadows, color treatments, and layered visual polish.",
  "Multimedia and capture" => "Play, record, route, and capture native audio, video, camera, screen, and window sources.",
  "Models and utilities" => "Connect native models, settings, paths, filesystem listings, filtering, and the system clipboard."
}.freeze

DESCRIPTIONS = {
  "accordion" => "An animated multi-section disclosure control that can keep one or several sections expanded.",
  "animation" => "A declarative native animation track for moving any supported property between values.",
  "application_window" => "The top-level native desktop window with sizing, visibility, typography, and focus events.",
  "avatar" => "A compact identity surface that displays an image or derives a fallback from a name.",
  "badge" => "A compact count or status marker with capped values and dot mode.",
  "button" => "Zui's primary native action control with icons, tooltips, hover state, URLs, and click events.",
  "canvas" => "A retained command-driven canvas for custom 2D drawing and pointer interaction.",
  "card" => "A polished content container with padding, spacing, border, radius, color, and accent treatment.",
  "chart_area_series" => "A QtCharts area series filled between an upper boundary and either a lower boundary or the axis.",
  "chart_bar_category_axis" => "A QtCharts axis of discrete string categories, for the bar series families.",
  "chart_bar_series" => "A QtCharts grouped bar series holding chart_bar_set children, with bar width and value labels.",
  "chart_bar_set" => "One labelled set of bar values inside a QtCharts bar series, with its own colour, border and label styling.",
  "chart_box_plot_series" => "A QtCharts box plot series holding chart_box_set children, with box width and outline.",
  "chart_box_set" => "One box in a QtCharts box plot, taking the five-number summary in Qt's order: lower extreme, lower quartile, median, upper quartile, upper extreme.",
  "chart_candlestick_series" => "A QtCharts candlestick series with body and caps geometry and separate increasing and decreasing colours.",
  "chart_candlestick_set" => "One candle in a QtCharts candlestick series, carrying its timestamp and open, high, low and close values.",
  "chart_category_axis" => "A QtCharts axis that names ranges of values, holding chart_category_range children.",
  "chart_category_range" => "One named range on a QtCharts category axis, ending at the value given.",
  "chart_date_time_axis" => "A QtCharts time axis whose bounds accept milliseconds since the epoch or a date string, with a Qt date format.",
  "chart_h_bar_model_mapper" => "Maps rows of a table to the bar sets of a QtCharts bar series, with columns as the categories.",
  "chart_h_box_plot_model_mapper" => "Maps rows of a table to the box sets of a QtCharts box plot series.",
  "chart_h_candlestick_model_mapper" => "Maps table columns to the timestamp and OHLC fields of each candle, one candle per row.",
  "chart_h_pie_model_mapper" => "Maps one row of a table to pie values and another to the slice labels.",
  "chart_h_xy_model_mapper" => "Maps one row of a table to x values and another to y values for a QtCharts XY series.",
  "chart_horizontal_bar_series" => "A QtCharts grouped bar series drawn along the horizontal axis.",
  "chart_horizontal_percent_bar_series" => "A QtCharts horizontal bar series that scales each stack to a full hundred percent.",
  "chart_horizontal_stacked_bar_series" => "A QtCharts horizontal bar series that stacks each set on the one before it.",
  "chart_line_series" => "A QtCharts line series plotted inside a chart view, taking its points from an array or from chart_xy_point children.",
  "chart_log_value_axis" => "A logarithmic QtCharts axis with a configurable base, for series that span orders of magnitude.",
  "chart_percent_bar_series" => "A QtCharts bar series that scales each stack to a full hundred percent.",
  "chart_pie_series" => "A QtCharts pie or donut series holding chart_pie_slice children, with hole size, position and angle span.",
  "chart_pie_slice" => "One labelled slice of a QtCharts pie series, with label placement, colours and an explode offset.",
  "chart_scatter_series" => "A QtCharts scatter series with a choice of marker shape and size, plotted inside a chart view.",
  "chart_spline_series" => "A QtCharts spline series that smooths a curve through its points inside a chart view.",
  "chart_stacked_bar_series" => "A QtCharts bar series that stacks each set on the one before it.",
  "chart_v_bar_model_mapper" => "Maps columns of a table to the bar sets of a QtCharts bar series, with rows as the categories.",
  "chart_v_box_plot_model_mapper" => "Maps columns of a table to the box sets of a QtCharts box plot series.",
  "chart_v_candlestick_model_mapper" => "Maps table rows to the timestamp and OHLC fields of each candle, one candle per column.",
  "chart_v_pie_model_mapper" => "Maps one column of a table to pie values and another to the slice labels.",
  "chart_v_xy_model_mapper" => "Maps one column of a table to x values and another to y values for a QtCharts XY series.",
  "chart_value_axis" => "A linear QtCharts axis declared inside the series it scales, with tick count, interval, anchor and label format.",
  "chart_view" => "The real QtCharts chart surface: a container that holds Qt's own series, axes and sets, with theme, animation, margins and a full legend.",
  "chart_xy_point" => "A single point appended to the QtCharts XY series it is declared inside.",
  "checkbox" => "A labeled boolean input with native focus, hover, and change behavior.",
  "chip" => "A compact selectable or deletable label for filters, tags, and lightweight actions.",
  "color_picker" => "A native color selection control with optional alpha and dialog presentation.",
  "data_table" => "A high-level native table for structured rows, columns, selection, sorting, and activation.",
  "date_picker" => "A bounded native calendar input with formatted values and popup navigation.",
  "dialog" => "A composable modal surface with native focus management, close policy, and action events.",
  "dropdown" => "A labeled native choice control for selecting one value from a compact option list.",
  "file_picker" => "A native file chooser supporting filters, single or multiple selection, and folder state.",
  "graph_area_series" => "A QtGraphs area series filled between an upper boundary and either a lower boundary or the axis.",
  "graph_bar_3d_series" => "A series of 3D bars with its own mesh, colour style and row and column labels, fed by a data proxy child.",
  "graph_bar_category_axis" => "A QtGraphs axis of discrete string categories, declared inside the graph.",
  "graph_bar_model_mapper" => "Maps a table to the bar sets of a QtGraphs bar series. One orientation covers what QtCharts splits into separate horizontal and vertical mappers.",
  "graph_bar_series" => "A QtGraphs bar series holding graph_bar_set children. One bars_type covers grouped, stacked and percent layouts, where QtCharts needs six separate series types.",
  "graph_bar_set" => "One labelled set of bar values inside a QtGraphs bar series, with its own colours and border.",
  "graph_bars_3d" => "A GPU-rendered 3D bar graph with full camera, lighting, shadow and selection control. QtGraphs is Qt's replacement for QtDataVisualization.",
  "graph_category_3d_axis" => "An axis of discrete labels for a 3D graph, used for the row and column slots of a 3D bar graph.",
  "graph_custom_3d_item" => "A mesh placed in a 3D graph's own coordinate space, with position, scaling and an axis-and-angle rotation.",
  "graph_custom_3d_label" => "A text label placed in a 3D graph's own coordinate space, optionally turned to face the camera.",
  "graph_date_time_axis" => "A QtGraphs time axis whose bounds accept milliseconds since the epoch or a date string.",
  "graph_height_map_surface_data_proxy" => "Feeds a 3D surface series from a height map image, turning pixel luminance into the y value.",
  "graph_item_model_bar_data_proxy" => "Feeds a 3D bar series from an array of row objects, naming the keys that carry the row, column and value.",
  "graph_item_model_scatter_data_proxy" => "Feeds a 3D scatter series from an array of row objects, naming the keys that carry the x, y and z positions.",
  "graph_item_model_surface_data_proxy" => "Feeds a 3D surface series from an array of row objects, naming the keys that carry the grid position and the x, y and z values.",
  "graph_line_series" => "A QtGraphs line series rendered in a graphs view, with selectable and hoverable points.",
  "graph_log_value_3d_axis_formatter" => "Logarithmic grid and label placement for a 3D value axis, with a configurable base and edge labels.",
  "graph_pie_model_mapper" => "Maps a table to the values and labels of a QtGraphs pie series, in either orientation.",
  "graph_pie_series" => "A QtGraphs pie or donut series holding graph_pie_slice children.",
  "graph_pie_slice" => "One labelled slice of a QtGraphs pie series, with label placement, colours and an explode offset.",
  "graph_scatter_3d" => "A GPU-rendered 3D scatter graph with full camera, lighting, shadow and selection control.",
  "graph_scatter_3d_series" => "A series of 3D scatter items with a configurable mesh and item size, fed by a data proxy child.",
  "graph_scatter_series" => "A QtGraphs scatter series with point selection and dragging.",
  "graph_spline_series" => "A QtGraphs spline series that smooths a curve through its points.",
  "graph_surface_3d" => "A GPU-rendered 3D surface graph, with an option to flip the horizontal grid to the top.",
  "graph_surface_3d_series" => "A 3D surface series with draw mode, shading, texture and wireframe colour, fed by a data proxy child.",
  "graph_value_3d_axis" => "A linear axis for a 3D graph, with segment counts and an optional formatter child. Its position names either axisX/Y/Z or the row, column and value slots Bars3D uses.",
  "graph_value_3d_axis_formatter" => "The default grid and label placement for a 3D value axis, declared inside the axis it formats.",
  "graph_value_axis" => "A linear QtGraphs axis declared inside the graph, with sub-ticks, tick interval and label decimals.",
  "graph_xy_model_mapper" => "Maps a table to the x and y values of a QtGraphs XY series, in either orientation.",
  "graph_xy_point" => "A single point appended to the QtGraphs XY series it is declared inside.",
  "graphs_theme" => "A QtGraphs theme assigned to the graph it is declared inside, covering colour scheme, backgrounds, labels and every grid and axis line.",
  "graphs_view" => "QtGraphs' 2D graph surface. Unlike a QtCharts chart it owns its axes directly and takes series through addSeries.",
  "grid_layout" => "A native grid layout with explicit rows, columns, gaps, alignment, and layout constraints.",
  "image" => "A native raster image renderer with asynchronous loading, cache, transforms, and fill modes.",
  "line_chart" => "A responsive native line chart with labels, points, grids, bounds, and selection events.",
  "list_view" => "A streamlined native collection view with keys, labels, descriptions, icons, and activation.",
  "markdown" => "A native Qt Markdown text renderer with wrapping, line limits, base URLs, and link events.",
  "media_player" => "A stateful native media engine for playback, tracks, position, buffering, and device routing.",
  "model_view_3d" => "An interactive Qt Quick 3D model viewport with orbit, zoom, lighting, fit, and status events.",
  "multi_select" => "A searchable multiple-choice control supporting static or command-provided options.",
  "navigation_rail" => "A compact or extended navigation rail for switching between primary destinations.",
  "number_field" => "A labeled numeric field with range, step, compact sizing, and change events.",
  "particle_system" => "A configurable native particle emitter with motion, gravity, turbulence, bursts, and lifecycle events.",
  "polar_chart_view" => "A QtCharts chart drawn on polar axes, where series take angular and radial axes instead of x and y.",
  "progress_ring" => "A circular determinate or indeterminate progress indicator with native animation.",
  "search_field" => "A live search input with suggestions, keyboard highlighting, clearing, and activation.",
  "shader_effect" => "A GPU shader surface with uniforms, source textures, time, pointer data, and frame events.",
  "slider" => "A native ranged input with snapping, optional integer values, ticks, and live input events.",
  "stack_view" => "A navigable stack of native pages with depth, push/pop, transition, and busy state.",
  "tabs" => "A complete tabbed content container with native selection, position, and keyboard behavior.",
  "text_field" => "A native single-line text input with placeholder, selection, focus, submit, and reactive input events.",
  "timer" => "A declarative native timer for one-shot or repeating triggers.",
  "toast" => "A short-lived non-modal feedback message with placement, duration, severity, and dismissal.",
  "toggle" => "A descriptive boolean setting row with label, supporting copy, and change events.",
  "video" => "A convenient native video player surface with looping, orientation, mirroring, and transport events."
}.freeze

def title_for(slug)
  slug.split("_").map { |part| part == "3d" ? "3D" : part.capitalize }.join(" ")
end

def slugify(value)
  value.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
end

def category_map
  current = nil
  SOURCE_ROOT.join("docs/component-coverage.md").each_line.with_object({}) do |line, map|
    if (match = line.match(/^## (.+)$/))
      current = match[1]
    elsif current && (match = line.match(/^- \[x\] `?([a-z0-9_]+)`?$/i))
      map[match[1]] = current
    end
  end
end

categories_for = category_map
schema = Zui::DEFAULT_COMPONENTS.protocol_schema
revision, = Open3.capture2("git", "rev-parse", "HEAD", chdir: SOURCE_ROOT.to_s)
revision = revision.strip

components = schema.keys.sort.map do |slug|
  component = schema.fetch(slug)
  category = categories_for.fetch(slug, "Models and utilities")
  specific_properties = Zui::COMPONENTS.fetch(slug.to_sym).first.map(&:to_s)
  title = title_for(slug)
  description = DESCRIPTIONS.fetch(slug) do
    "#{title} is a native Zui #{component.fetch("container") ? "container" : "component"} in the #{category.downcase} catalog, with #{specific_properties.length} component-specific properties."
  end

  {
    "slug" => slug,
    "title" => title,
    "category" => category,
    "category_slug" => slugify(category),
    "description" => description,
    "qml" => component.fetch("qml"),
    "container" => component.fetch("container"),
    "auto_bind" => component.fetch("auto_bind"),
    "properties" => component.fetch("properties"),
    "specific_properties" => specific_properties,
    "events" => component.fetch("events"),
    "example" => ZuiExamples.for(slug, category),
    "search_text" => ([ slug, title, category, description ] + specific_properties + component.fetch("events")).join(" ").downcase
  }
end

categories = CATEGORY_DESCRIPTIONS.map do |name, description|
  {
    "name" => name,
    "slug" => slugify(name),
    "description" => description,
    "count" => components.count { |component| component.fetch("category") == name }
  }
end

payload = {
  "metadata" => {
    "zui_version" => Zui::VERSION,
    "source_revision" => revision,
    "component_count" => components.length,
    "category_count" => categories.length,
    "property_count" => components.sum { |component| component.fetch("properties").length },
    "event_count" => components.sum { |component| component.fetch("events").length },
    "generated_at" => Time.now.utc.iso8601
  },
  "categories" => categories,
  "components" => components
}

OUTPUT_PATH.write(JSON.pretty_generate(payload) + "\n")
puts "Synced #{components.length} components from Zui #{Zui::VERSION} (#{revision[0, 12]})"
