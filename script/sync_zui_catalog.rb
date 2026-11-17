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
  "checkbox" => "A labeled boolean input with native focus, hover, and change behavior.",
  "chip" => "A compact selectable or deletable label for filters, tags, and lightweight actions.",
  "color_picker" => "A native color selection control with optional alpha and dialog presentation.",
  "data_table" => "A high-level native table for structured rows, columns, selection, sorting, and activation.",
  "date_picker" => "A bounded native calendar input with formatted values and popup navigation.",
  "dialog" => "A composable modal surface with native focus management, close policy, and action events.",
  "dropdown" => "A labeled native choice control for selecting one value from a compact option list.",
  "file_picker" => "A native file chooser supporting filters, single or multiple selection, and folder state.",
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
  "emitter" => "A particle source that feeds a system by id, with its own rate, lifetime, size, shape, and burst and pulse control.",
  "trail_emitter" => "An emitter that follows the particles of another group so one group can trail another.",
  "image_particle" => "A textured particle painter with color, rotation, deformation vectors, gradient tables, and entry effects.",
  "item_particle" => "A particle painter that carries live Zui items, taking and giving them back as its list changes.",
  "particle_group" => "A named particle stage with its own lifetime and the weighted transitions it takes when that lifetime ends.",
  "ellipse_shape" => "An elliptical emission area, filled or outlined, for an emitter or affector.",
  "rectangle_shape" => "A rectangular emission area, filled or outlined, for an emitter or affector.",
  "line_shape" => "A diagonal emission line, optionally mirrored, for an emitter or affector.",
  "mask_shape" => "An emission area read from an image mask so particles spawn inside arbitrary artwork.",
  "angle_direction" => "A particle vector given as an angle and magnitude, each with its own variation.",
  "point_direction" => "A particle vector given as x and y components, each with its own variation.",
  "target_direction" => "A particle vector aimed at a point or a rendered item, optionally scaled by distance.",
  "cumulative_direction" => "A particle vector that sums several directions so one particle carries independent contributions.",
  "affector" => "Qt's general-purpose affector, offsetting particle position, velocity, and acceleration by given directions.",
  "age" => "An affector that cuts the remaining life of the particles it touches short.",
  "attractor" => "An affector that pulls particles toward a point, optionally falling off with distance.",
  "friction" => "An affector that slows particles in proportion to their velocity, down to a threshold.",
  "gravity" => "An affector that accelerates particles in a fixed direction.",
  "group_goal" => "An affector that moves the particles it touches toward another particle group.",
  "sprite_goal" => "An affector that moves the particles it touches toward a sprite state.",
  "turbulence" => "An affector that pushes particles with a noise field, tiled to keep the grid bounded.",
  "wander" => "An affector that adds random drift so a group does not travel in straight lines.",
  "timeline" => "A frame range that drives the keyframed properties of any number of targets from one scrubbable number.",
  "keyframe" => "One value a property holds at one frame, with the easing used to reach it.",
  "keyframe_group" => "The keyframes one property of one target passes through, so properties can share a timeline.",
  "timeline_animation" => "An animation that plays a timeline's frame range, with optional ping-pong playback.",
  "timeline_animation_node" => "A blend-tree input built from one timeline and one of its animations.",
  "blend_animation_node" => "A blend-tree node that mixes two inputs by weight so animations cross-fade instead of cutting.",
  "sprite" => "A named sprite-sheet state with its frame geometry, timing, and weighted transitions.",
  "animated_sprite" => "A single sprite sheet played as a frame animation, with loops and finish behavior.",
  "sprite_sequence" => "Several named sprite states played in turn, moving by weighted chance or toward a goal.",
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
