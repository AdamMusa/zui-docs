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
  "3D and spatial" => "Build GPU scenes with Qt Quick 3D: cameras, lights, materials, textures, geometry, instancing, particles, post-processing, and spatial audio."
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
  "view_3d" => "The Qt Quick 3D viewport that owns a GPU scene, adopts the camera and environment declared inside it, and reports picks.",
  "node_3d" => "A transform in a 3D scene that moves, rotates, and scales everything declared inside it.",
  "model_3d" => "A renderable mesh from a built-in primitive, a mesh asset, or a declared geometry, with materials, skinning, morphing, and instancing.",
  "loader_3d" => "Loads a 3D sub-scene from a QML asset on demand so a heavy branch is only built when it is needed.",
  "repeater_3d" => "Repeats everything declared inside it once per model entry, offset by a spacing step.",
  "perspective_camera" => "A perspective camera with field of view, clipping planes, frustum culling, and an optional look-at node.",
  "orthographic_camera" => "A parallel-projection camera for plans, diagrams, and isometric scenes.",
  "frustum_camera" => "A perspective camera whose frustum is given by its four side planes, for an asymmetric or off-centre projection.",
  "custom_camera" => "A camera driven by an explicit 4x4 projection matrix for a projection no other camera can describe.",
  "directional_light" => "Light arriving from one direction everywhere in the scene, with cascaded shadow maps and soft shadow filtering.",
  "point_light" => "Light radiating from a single point, fading with distance through constant, linear, and quadratic terms.",
  "spot_light" => "Light radiating in a cone, fading between an inner and an outer cone angle.",
  "principled_material" => "The metal-roughness physically based material, with clearcoat, transmission, thickness, height mapping, Fresnel control, and vertex colour masks.",
  "default_material" => "The pre-physically-based material, with a diffuse colour, an explicit specular model, and bump and translucency maps.",
  "specular_glossy_material" => "The specular-glossiness physically based material, for assets authored against that workflow.",
  "custom_material" => "A material whose shading is written as vertex and fragment shaders, with its own blend equation and documented uniform slots.",
  "texture_3d" => "An image sampled by a material, from an asset, from procedural data, or from a live two-dimensional Zui control.",
  "cube_map_texture" => "A six-faced texture for a skybox, an environment reflection, or a point light's shadow cube.",
  "texture_input" => "Hands a texture to a custom material or effect as a named shader input that can be switched off.",
  "scene_environment" => "How a viewport renders the space around its geometry: background, antialiasing, ambient occlusion, image based lighting, and tonemapping.",
  "extended_scene_environment" => "A scene environment with Qt's built-in post-processing chain: depth of field, glow, vignette, lens flare, and a colour lookup table.",
  "fog" => "Atmospheric fog for a scene environment, with independent depth, height, and transmission curves.",
  "debug_settings" => "Rendering diagnostics for a scene environment: wireframe, a material channel override, and shadow and cascade bounds.",
  "lightmapper" => "Settings for baking lightmaps: sample count, bounces, bias, and the indirect light contribution.",
  "baked_lightmap" => "Names the baked lightmap a model loads, and whether to use it.",
  "reflection_probe" => "Captures the scene around a point into a cube map so nearby materials can reflect it, with a box volume and parallax correction.",
  "resource_loader" => "Loads meshes, textures, and geometries before anything needs them so a scene does not stall on first use.",
  "skeleton_3d" => "The root of a joint hierarchy a model is skinned by.",
  "joint_3d" => "One bone of a skeleton, indexed to match the joint weights the mesh was authored with.",
  "skin_3d" => "Skinning without a skeleton: a flat list of nodes to deform by, each with its inverse bind pose.",
  "morph_target" => "One shape a mesh can be blended towards, weighted from 0 to 1 over named vertex channels.",
  "instance_list" => "Draws one mesh many times in a single GPU pass from declared per-instance entries.",
  "instance_list_entry" => "One instance of an instance list: its transform, colour, and four custom floats a shader can read.",
  "random_instancing" => "Generates instances from random values inside declared ranges, with a repeatable seed.",
  "instance_range" => "The bounds a random instance value is drawn from, either per component or proportionally.",
  "file_instancing" => "Instances loaded from a binary instance table on disk, for a field too large to declare node by node.",
  "effect_3d" => "A post-processing effect written as render passes, run by the scene environment that declares it.",
  "pass_3d" => "One render pass of an effect: its shaders, the commands that bind its inputs, and the buffer it writes to.",
  "shader_3d" => "One shader stage of a render pass, loaded from a vertex or fragment shader asset.",
  "buffer_3d" => "An intermediate render target a pass writes to and a later pass samples, scaled against the viewport.",
  "buffer_input" => "Binds a buffer to a named sampler of its pass, which is how one pass reads what another wrote.",
  "set_uniform_value" => "Sets one named uniform of its pass, so a shader value can be driven from Ruby.",
  "orbit_camera_controller" => "Turns a camera around a node by dragging and zooms with the wheel or a pinch.",
  "wasd_controller" => "Moves a node with the W, A, S, and D keys and turns it with the mouse.",
  "look_at_node" => "A node that keeps facing another one, so whatever is inside it stays turned towards a target.",
  "lod_manager" => "Shows one of its children at a time according to camera distance, so a distant model is drawn by a cheaper mesh.",
  "axis_helper" => "Draws the three axes and a grid on each plane, as a frame of reference for a scene under construction.",
  "debug_view_3d" => "An overlay reporting what a viewport is spending its frame on, including resource details.",
  "infinite_grid" => "A ground grid drawn to the horizon by the viewport rather than by geometry.",
  "grid_geometry" => "Line geometry for a grid of a declared size and step, for a model with a line-drawing material.",
  "height_field_geometry" => "A terrain mesh built from the brightness of a height map image, scaled to declared extents.",
  "procedural_mesh" => "A mesh built from vertex arrays declared in Ruby, with an index array, a primitive mode, and named subsets.",
  "procedural_mesh_subset" => "One named run of a procedural mesh's index array, so that part can take its own material.",
  "procedural_texture_data" => "Texture content generated in Ruby rather than loaded from a file.",
  "procedural_sky_texture_data" => "A generated sky with horizon, zenith, and ground colours and a placed sun, usable as a light probe.",
  "instance_model" => "Exposes an instancing table as a list model, one row per instance.",
  "instance_repeater" => "Builds a real node per row of an instancing table, for when each copy must be pickable or carry children.",
  "particle_system_3d" => "A GPU particle system whose clock can be driven from Ruby, owning the particles, emitters, and affectors declared inside it.",
  "sprite_particle_3d" => "Particles drawn as camera-facing sprites, with sprite sequences, colour tables, fade effects, and sorting.",
  "line_particle_3d" => "Sprite particles drawn as a ribbon through the positions each particle has passed.",
  "model_particle_3d" => "Particles drawn as real geometry rather than sprites, instanced on the GPU.",
  "model_blend_particle_3d" => "Takes a model apart into one particle per vertex or triangle and blends it between its shape and the particle motion.",
  "sprite_sequence_3d" => "Animates a sprite particle's image through the frames of a sprite sheet.",
  "particle_emitter_3d" => "Spawns particles into a system at a declared rate, lifetime, scale, and rotation, shaped and aimed by its children.",
  "trail_emitter_3d" => "An emitter that spawns from where another particle already is, so one particle leaves a trail of another.",
  "emit_burst_3d" => "A burst of particles at a fixed time on the system's clock.",
  "dynamic_burst_3d" => "A burst triggered by a particle's own start or end rather than by the clock.",
  "particle_shape_3d" => "The cube, sphere, or cylinder volume an emitter spawns particles in, filled or on its surface only.",
  "particle_model_shape_3d" => "Spawns particles over the surface or through the volume of a mesh.",
  "particle_custom_shape_3d" => "Spawns particles at positions baked into a shape file authored outside the application.",
  "vector_direction_3d" => "Sends particles along one direction with a declared spread.",
  "target_direction_3d" => "Sends particles towards a point with a declared spread and speed.",
  "gravity_3d" => "Accelerates particles along a direction, which is gravity pointing down and wind pointing anywhere else.",
  "attractor_3d" => "Pulls particles towards a position or towards points on a shape over a given duration.",
  "wander_3d" => "Adds a drifting motion, shared across all particles or unique to each.",
  "repeller_3d" => "Pushes particles away from its position, fading between an inner and an outer radius.",
  "point_rotator_3d" => "Spins particles around an axis through its position, for a vortex or a swirl.",
  "scale_affector_3d" => "Scales particles over their life through a declared curve and easing.",
  "runtime_loader" => "Loads a glTF, OBJ, or FBX asset into the scene while the application runs, and reports its status and bounds.",
  "quaternion_animation" => "Animates a 3D node's orientation along the shortest arc between two rotations, given as quaternions or Euler angles.",
  "audio_engine" => "The spatial audio engine a scene's sounds are mixed through, in surround, stereo, or headphone mode.",
  "audio_listener" => "Where a scene is heard from; the mix follows the node it is declared inside.",
  "audio_room" => "A box of space with an acoustic material on each wall, so reflections and reverberation match what the room is built of.",
  "spatial_sound" => "A sound at a place in the scene, attenuated by distance, occluded by rooms, and optionally directional.",
  "ambient_sound" => "A sound with no position, heard evenly wherever the listener stands.",
  "additive_color_gradient" => "Adds a vertical colour gradient over the scene, the cheapest way to tint a sky or ground.",
  "blur_3d" => "A light blur of the whole 3D scene as a post-processing pass.",
  "brush_strokes" => "Displaces the scene along a noise texture so it looks painted.",
  "chromatic_aberration" => "Separates the colour channels towards the edges the way a real lens does.",
  "color_master" => "Per-channel gain plus saturation, for grading a whole 3D scene.",
  "depth_of_field_hq_blur" => "Blurs whatever lies outside a focus range measured in depth from the camera.",
  "desaturate" => "Pulls the colour out of a 3D scene, down to grey.",
  "distortion_ripple" => "Bends the scene in rings spreading from a point.",
  "distortion_sphere" => "Bends the scene as though seen through a glass sphere.",
  "distortion_spiral" => "Twists the scene around a point.",
  "edge_detect" => "Keeps only the edges in a 3D scene, for a line-drawn look.",
  "emboss" => "Turns differences in brightness into a raised relief.",
  "flip" => "Mirrors a 3D scene horizontally, vertically, or both.",
  "fxaa" => "Fast approximate antialiasing as a post-processing pass.",
  "gaussian_blur" => "A true Gaussian blur of a whole 3D scene.",
  "hdr_bloom_tonemap" => "Blooms the bright parts of a scene and tonemaps the result, so lights look bright rather than pale.",
  "motion_blur" => "Smears a 3D scene along the motion between frames.",
  "s_curve_tonemap" => "Tonemaps through an S-shaped curve with separate control over the shoulder and the toe.",
  "scatter" => "Scatters pixels along a noise texture, for frosted glass or interference.",
  "tilt_shift" => "Keeps a band of a 3D scene sharp and blurs the rest, the way a tilt-shift lens does.",
  "vignette_3d" => "Darkens a 3D scene towards the corners."
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
