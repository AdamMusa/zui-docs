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
  "Models and utilities" => "Connect native models, settings, paths, filesystem listings, filtering, and the system clipboard.",
  "Mobile permissions" => "Request and observe the platform permissions a device capability needs before it can be used.",
  "Mobile sensors" => "Read device motion, orientation, environment, and proximity through the native QtSensors backends.",
  "Mobile positioning" => "Track device position and satellites, and describe places as structured coordinates and addresses.",
  "Mobile maps" => "Render native maps, choose a geo service provider, and query geocoding, routing, and places.",
  "Mobile speech" => "Speak text through the platform engine and inspect the voices and locales it offers.",
  "Mobile web content" => "Embed the platform web view and open native WebSocket clients and servers.",
  "Mobile virtual keyboard" => "Present and configure Qt's on-screen keyboard, handwriting input, and input context."
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
  "video" => "A convenient native video player surface with looping, orientation, mirroring, and transport events.",

  # Sensors. Qt's reading types are uncreatable, so each sensor reports its values on a
  # reading event and its QtSensors metadata on a metadata event.
  "sensor_manager" => "Enumerates the sensor types the device registers, the backends behind each one, and each type's default.",
  "accelerometer" => "Reports device acceleration on three axes, with the sensor's data rates, output ranges, and buffering. Needs the Android HIGH_SAMPLING_RATE_SENSORS permission above 200 Hz and an iOS NSMotionUsageDescription.",
  "gyroscope" => "Reports angular velocity on three axes for rotation-aware interfaces. Needs an iOS NSMotionUsageDescription.",
  "magnetometer" => "Reports the magnetic field on three axes with its calibration level. Needs an iOS NSMotionUsageDescription.",
  "compass" => "Reports device azimuth and calibration level for heading-aware interfaces. Needs an iOS NSMotionUsageDescription.",
  "rotation_sensor" => "Reports device rotation on three axes, and whether the backend provides the z axis at all. Needs an iOS NSMotionUsageDescription.",
  "tilt_sensor" => "Reports x and y tilt and can recalibrate its zero point to the device's current attitude. Needs an iOS NSMotionUsageDescription.",
  "tap_sensor" => "Reports taps on the device body, optionally distinguishing double taps. Needs an iOS NSMotionUsageDescription.",
  "orientation_sensor" => "Reports which way up the device is held, as a discrete orientation.",
  "proximity_sensor" => "Reports whether an object is near the device, for screen-off-on-ear behaviour.",
  "ir_proximity_sensor" => "Reports raw infrared reflectance, the continuous measurement behind proximity detection.",
  "light_sensor" => "Reports measured illuminance in lux for adaptive brightness.",
  "ambient_light_sensor" => "Reports ambient light as a discrete level, from dark to sunny.",
  "ambient_temperature_sensor" => "Reports ambient air temperature in degrees Celsius.",
  "humidity_sensor" => "Reports relative and absolute humidity from the device's hygrometer.",
  "pressure_sensor" => "Reports barometric pressure, and sensor temperature where the backend supplies it.",
  "lid_sensor" => "Reports whether the front or back lid of a convertible device is closed.",

  # Positioning.
  "position_source" => "Tracks device position with accuracy, speed, direction, and per-field validity, and can be started, stopped, and updated on demand. Needs an Android location permission and an iOS NSLocationWhenInUseUsageDescription.",
  "satellite_source" => "Reports the satellites in view and in use with signal strength, elevation, azimuth, and satellite system. Needs an Android location permission and an iOS NSLocationWhenInUseUsageDescription.",
  "geo_address" => "A structured postal address that keeps Qt's generated single-line label when no explicit text is given.",
  "geo_location" => "A place as a coordinate plus its address, bounding shape, and extended attributes.",
  "coordinate_animation" => "Animates a map coordinate along a great circle, with shortest, eastward, or westward direction.",

  # Maps.
  "map_plugin" => "Chooses and configures a geo service provider once, reports what it supports, and shares it across maps and models.",
  "map" => "A native interactive map with pan, pinch, and wheel gestures, selectable map types, and tap events. Online providers need the Android INTERNET permission.",
  "map_circle" => "A filled circle of a given radius drawn on a map at a coordinate.",
  "map_rectangle" => "A rectangular region drawn on a map between two corner coordinates.",
  "map_polygon" => "A filled polygon drawn on a map through a list of coordinates.",
  "map_polyline" => "A stroked path drawn on a map through a list of coordinates.",
  "map_route" => "A stroked route line drawn on a map, for rendering a computed route.",
  "map_marker" => "A map item that anchors arbitrary Zui content to a coordinate.",
  "map_item_group" => "Groups map items so they can be shown, hidden, and reasoned about together.",
  "map_item_view" => "Renders one map marker per row of a collection, bound to latitude, longitude, and label fields.",
  "map_copyright" => "The provider attribution a map is required to display, with link events.",
  "geo_json_data" => "Loads and saves GeoJSON as map items for rendering on a map.",
  "geocode_model" => "Resolves an address or coordinate into located results through the provider's geocoding service.",
  "route_model" => "Computes routes between waypoints with travel mode, optimization, and alternatives.",
  "place_search" => "Searches the provider's place database within an area, with relevance and recommendation modes.",
  "place_suggestions" => "Returns search-as-you-type suggestions for a partial place term.",
  "place_categories" => "Lists the provider's place categories, flat or hierarchical.",
  "place_details" => "Loads, saves, and removes a single place and its attribution.",
  "place_category" => "Loads, saves, and removes a single place category.",

  # Device, speech, web, and keyboard.
  "text_to_speech" => "Speaks text through the platform engine, and reports the voices, locales, and capabilities it offers.",
  "web_view" => "Embeds the platform web view with navigation, cookies, JavaScript evaluation, and effective settings readback. Needs the Android INTERNET permission.",
  "virtual_keyboard" => "Presents Qt's on-screen keyboard and reports its active state and language switches.",
  "handwriting_input" => "An overlay that turns strokes into text through Qt's handwriting recogniser.",
  "keyboard_context" => "The shared input context: commits text, sends keys, and reports locale changes.",
  "keyboard_settings" => "Configures the on-screen keyboard's style, locales, full-screen mode, and dictionaries.",
  "keyboard_text_field" => "A text field wired to the on-screen keyboard's enter-key action and input-method hints.",

  # PDF.
  "pdf_document" => "Loads a PDF once and reports its metadata, page labels, and page sizes, to be shared by several views.",
  "pdf_multi_page_view" => "A continuously scrolling multi-page PDF view with zoom, rotation, search, and selection.",
  "pdf_page_view" => "A single-page PDF view with its own pinch and wheel zoom.",
  "pdf_scrollable_page_view" => "A single-page PDF view inside a scroll view, with zoom and rotation.",
  "pdf_page_image" => "One PDF page rendered as an image at a chosen resolution.",
  "pdf_page_navigator" => "A standalone PDF navigation history for building a custom viewer, with jump, back, and forward.",
  "pdf_search_model" => "Searches a PDF and reports each hit's page, position, and surrounding context.",
  "pdf_selection" => "Selects text in a PDF between two points, and copies it to the clipboard.",
  "pdf_link_model" => "Lists the links on a PDF page, distinguishing web links from internal destinations.",
  "pdf_bookmark_model" => "Walks a PDF outline one branch at a time, listing each entry's title, level, and destination.",
  "video_sink" => "Receives frames from a media player or capture session without drawing them, to confirm frames are arriving and at what size.",

  # Models: QtQml.Models, QtQml.XmlListModel, Qt.labs.qmlmodels.
  "object_model" => "Holds a container's declared child controls as a model, so a view can present a fixed, heterogeneous set of controls.",
  "instantiator" => "Creates a container's children on demand, optionally asynchronously, reporting each object as it appears and leaves.",
  "item_selection_model" => "Tracks which rows of a model are selected and which row is current, applying the selection Ruby declares and reporting what changes.",
  "xml_list_model" => "Fetches an XML document and exposes the elements matched by an XPath query as rows keyed by role, with load status and progress.",
  "xml_list_model_role" => "Maps one role of an xml_list_model row to an element or an attribute of the matched XML node.",
  "table_model" => "A native table model built from Ruby rows and declared columns, carrying Qt's full column role surface.",
  "table_model_column" => "Declares one table_model column and which row key supplies each of its Qt roles, from display to check state.",
  "locale" => "Answers locale questions from Qt's CLDR data and formats numbers, currency, dates, times, and data sizes for a named or system locale.",

  # Bindings and the hierarchical state machine: QtQml, QtQml.StateMachine.
  "property_binding" => "A live declarative link that keeps one control's property following another's, gated by a condition and restored when it lapses.",
  "state_machine" => "A hierarchical state machine with nested and parallel regions, history and timed transitions, driven by named events from Ruby.",
  "machine_state" => "One state of a state_machine, which may nest its own child states and transitions and reports its own entry and exit.",
  "final_state" => "A terminal state that finishes its enclosing state_machine when it is entered.",
  "history_state" => "A pseudo-state that returns a compound state to the child it last occupied, either shallowly or deeply.",
  "signal_transition" => "Moves a state_machine out of its enclosing state when Ruby fires the event it listens for.",
  "timeout_transition" => "Moves a state_machine out of its enclosing state once that state has been active for a set time."
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
