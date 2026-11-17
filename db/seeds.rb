guides = [
  {
    position: 1,
    slug: "quickstart",
    title: "Quickstart",
    summary: "Install Zui, configure the native client, and open your first Ruby-owned desktop window.",
    body: <<~HTML
      <h2>Start with one Ruby file</h2>
      <p>Zui applications are Ruby and assets. The native Qt client renders the component tree, while your Ruby process owns state, events, scheduling, and application logic.</p>
      <pre data-language="bash"><code class="language-bash">gem install zui
zui doctor --fix
zui new telemetry-console
cd telemetry-console
zui run main.rb</code></pre>
      <h2>Your first surface</h2>
      <p>Define an application module and return a native surface from <code>Zui.app</code>. Containers accept nested Ruby blocks, so hierarchy remains obvious.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

module Counter
  def self.run
    Zui.app do
      state :count, 0

      app :main, title: "Counter", width: 640, height: 420 do
        card padding: 24, spacing: 16 do
          label "Counter", bold: true
          text { "Count: \#{state.count}" }
          button("Increment") { state.count += 1 }
        end
      end
    end
  end
end

Counter.run</code></pre>
      <h2>Configure once per version</h2>
      <p><code>zui doctor --fix</code> downloads the matching native client, checks its checksum and manifest, and stores it in Zui's versioned user cache. Your gem stays small, and application bundles use their own private client copy.</p>
      <blockquote>Zui never downloads a browser engine. The client contains the Qt/QML host and the libraries needed by native components.</blockquote>
      <h2>Build a distributable app</h2>
      <pre data-language="bash"><code class="language-bash">zui bundle</code></pre>
      <p>The bundle combines your application, assets, the Zui framework runtime, and the configured native client for the current platform.</p>
    HTML
  },
  {
    position: 2,
    slug: "state-and-bindings",
    title: "State and bindings",
    summary: "Model reactive application state and update only the native properties that changed.",
    body: <<~HTML
      <h2>State belongs to Ruby</h2>
      <p>Declare state inside the application definition. Read it from binding blocks; changing a value schedules the smallest valid native patch.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :status, "Ready"
  state :progress, 0

  app :main, title: "Build monitor", width: 640, height: 420 do
    column spacing: 16 do
      label { state.status }

      progress_bar = progress state.progress, minimum: 0, maximum: 100
      bind(progress_bar, :value) { state.progress }

      button "Start" do
        transaction do
          state.status = "Working"
          state.progress = 12
        end
      end
    end
  end
end</code></pre>
      <h2>Bind any registered property</h2>
      <p>Convenience helpers bind their primary value, while <code>bind</code> connects any registered property to a Ruby reader.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :panel_visible, true

  app :main, title: "Animated binding", width: 640, height: 420 do
    column spacing: 16 do
      panel = card padding: 24 do
        label "Bound panel"
      end

      bind panel, :opacity, animation: animation(duration: 240) do
        state.panel_visible ? 1.0 : 0.0
      end

      button "Toggle panel" do
        state.panel_visible = !state.panel_visible
      end
    end
  end
end</code></pre>
      <h2>Render collections with ordinary Ruby</h2>
      <p>Container blocks accept normal Ruby iteration when building a collection. Keep item identity in ordinary Ruby data and use state for values that change after rendering.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

devices = [
  { id: "display", name: "Studio Display" },
  { id: "headphones", name: "USB Headphones" }
]

Zui.app do
  state :selected_id, devices.first.fetch(:id)

  app :main, title: "Devices", width: 640, height: 420 do
    column spacing: 8 do
      devices.each do |device|
        button device.fetch(:name) do
          state.selected_id = device.fetch(:id)
        end
      end

      text { "Selected: \#{state.selected_id}" }
    end
  end
end</code></pre>
    HTML
  },
  {
    position: 3,
    slug: "events-and-commands",
    title: "Events and commands",
    summary: "Handle native interaction, schedule work, and run bounded external commands without leaving Ruby.",
    body: <<~HTML
      <h2>Handle intent with blocks</h2>
      <p>High-level component helpers register their primary event automatically. Pass external commands as argument arrays, and set explicit time and output bounds.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :loading, false
  state :output, "Select Refresh to inspect the service."

  app :main, title: "Service status", width: 760, height: 520 do
    column spacing: 16 do
      button "Refresh", icon: :refresh do
        state.loading = true

        async do
          result = run_command(
            ["systemctl", "--user", "status", "example.service"],
            timeout: 5,
            max_output_bytes: 65_536
          )
          state.output = result.success? ? result.stdout : result.stderr
        rescue Zui::CommandTimeout => error
          state.output = error.message
        ensure
          state.loading = false
        end
      end

      text { state.loading ? "Loading…" : state.output }
    end
  end
end</code></pre>
      <h2>Subscribe to any declared event</h2>
      <p>Keep the node returned by a component helper, then subscribe with an event declared by that component.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :selected_index, nil
  values = [18, 42, 31, 76, 58, 91]

  app :main, title: "Traffic", width: 760, height: 520 do
    column spacing: 16 do
      chart = line_chart values, show_points: true, width: 680, height: 320

      on chart, :select do |payload|
        state.selected_index = payload["index"]
      end

      text { "Selected point: \#{state.selected_index || "none"}" }
    end
  end
end</code></pre>
      <h2>Schedule without blocking the UI</h2>
      <p>Use <code>every</code> for recurring work and <code>after</code> for a one-shot update. Intervals are expressed in seconds.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :sample, 0.0
  state :notice, "Starting sampler…"

  every 5, immediate: true do
    state.sample = Process.clock_gettime(Process::CLOCK_MONOTONIC).round(2)
  end

  after 0.25 do
    state.notice = "Sampler ready"
  end

  app :main, title: "Sampler", width: 640, height: 420 do
    column spacing: 12 do
      label { state.notice }
      text { "Monotonic sample: \#{state.sample}" }
    end
  end
end</code></pre>
      <p>Event names and properties are validated against the catalog before they reach the native protocol.</p>
    HTML
  },
  {
    position: 4,
    slug: "layout-and-surfaces",
    title: "Layout and surfaces",
    summary: "Compose windows, grids, stacks, scroll regions, and reusable application-owned UI modules.",
    body: <<~HTML
      <h2>Surfaces frame the application</h2>
      <p>Desktop applications start with <code>app</code>. Omarchy adapters can host the same application UI in panels and bar widgets.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

destinations = [
  { label: "Overview", icon: :house },
  { label: "Activity", icon: :clock },
  { label: "Settings", icon: :gear }
]

Zui.app do
  state :section, 0

  app :main, title: "Operations", width: 1100, height: 760 do
    row_layout spacing: 20 do
      rail = navigation_rail destinations,
        current_index: state.section,
        extended: true,
        width: 220

      on rail, :change do |payload|
        state.section = payload.fetch("current_index", payload["index"])
      end

      scroll fill_width: true, fill_height: true do
        column spacing: 16 do
          label "Operations", size: 32, bold: true

          grid_layout columns: 2, spacing: 12 do
            card(padding: 18) { label "Requests: 14.2k" }
            card(padding: 18) { label "Latency: 42 ms" }
          end
        end
      end
    end
  end
end</code></pre>
      <h2>Prefer layout constraints</h2>
      <p>Use <code>fill_width</code>, <code>preferred_width</code>, and the layout containers when content should adapt. Explicit dimensions remain useful for media, canvases, and deliberate fixed surfaces.</p>
      <h2>Keep reusable UI scoped</h2>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

module OperationsUI
  def metric_card(label, value)
    card padding: 18, spacing: 8 do
      text label, color: "#8b8b92"
      label value, size: 28, bold: true
    end
  end
end

application = Zui::Application.new(ui: OperationsUI) do
  app :main, title: "Operations", width: 760, height: 520 do
    grid_layout columns: 2, spacing: 12 do
      metric_card "Requests", "14.2k"
      metric_card "Latency", "42 ms"
    end
  end
end

application.run</code></pre>
    HTML
  },
  {
    position: 5,
    slug: "animation-and-effects",
    title: "Animation and effects",
    summary: "Add native transitions, sequenced motion, shaders, particles, shadows, and GPU-backed treatments.",
    body: <<~HTML
      <h2>Animate a reactive patch</h2>
      <p>Attach an animation to a binding when a state change should transition a native property instead of replacing it immediately.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :panel_visible, true

  app :main, title: "Animated binding", width: 640, height: 420 do
    column spacing: 16 do
      panel = card padding: 24 do
        label "Native transition"
      end

      bind(
        panel,
        :opacity,
        animation: animation(duration: 280, easing: :out_cubic)
      ) do
        state.panel_visible ? 1.0 : 0.0
      end

      button "Toggle panel" do
        state.panel_visible = !state.panel_visible
      end
    end
  end
end</code></pre>
      <h2>Sequence deliberate motion</h2>
      <p><code>animate_sequence</code> converts ordered steps into native animation tracks. Trigger the sequence from an event when the application is already running.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  app :main, title: "Motion sequence", width: 640, height: 420 do
    column spacing: 16 do
      hero = card padding: 24, opacity: 0.0, scale: 0.9 do
        label "Deployment ready", size: 24, bold: true
      end

      button "Reveal" do
        animate_sequence hero, [
          { to: { opacity: 1.0, scale: 1.0 }, duration: 260 },
          { to: { rotation: 2 }, duration: 90, pause: 40 },
          { to: { rotation: 0 }, duration: 140 }
        ]
      end
    end
  end
end</code></pre>
      <h2>Use the native GPU pipeline</h2>
      <p>Effects are containers, so their child becomes the source texture. Shader effects accept precompiled QSB shaders and bounded runtime uniforms.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  app :main, title: "GPU effects", width: 760, height: 520 do
    column spacing: 20 do
      glow color: "#b7ff5a", blur: 0.7, opacity: 0.8 do
        card padding: 24, color: "#111114" do
          label "Signal locked"
        end
      end

      shader_effect "assets/shaders/plasma.frag.qsb",
        width: 640,
        height: 300,
        running: true,
        intensity: 0.85
    end
  end
end
</code></pre>
    HTML
  },
  {
    position: 6,
    slug: "qt-modules-on-mobile",
    title: "Qt modules on mobile",
    summary: "Which Qt QML modules reach iOS and Android, what each one needs, and how Qt type names map to Zui components.",
    body: <<~HTML
      <h2>Components are Qt modules underneath</h2>
      <p>Every Zui component renders through a Qt QML type, and those types live in Qt modules that a mobile application has to carry. Zui works that out from your code: the tree shaker keeps only the component adapters your application references, the surviving QML is compiled into the application resource, and the Qt modules those adapters import are linked for the target. Nothing lists its Qt modules by hand.</p>
      <p>The consequence is worth knowing: if an application never uses <code>map</code>, no Qt Location library is in the binary at all. If it does, the module, its plugins and its Android permissions arrive with it.</p>
      <pre data-language="bash"><code class="language-bash">zui mobile --enable
zui mobile --fix
zui build ios
zui build android
zui install ios</code></pre>
      <h2>What reaches iOS and Android</h2>
      <p>Of the 76 public Qt QML modules in Qt 6.8.3, 28 are reachable today because a shipped adapter imports them. Both mobile SDKs carry all of them except Qt PDF.</p>
      <table>
        <thead><tr><th>Qt module</th><th>iOS</th><th>Android</th><th>SDK add-on</th><th>Android permissions it brings</th></tr></thead>
        <tbody>
          <tr><td><code>QtQuick</code>, <code>QtQuick.Controls</code>, <code>QtQuick.Layouts</code>, <code>QtQuick.Window</code>, <code>QtQuick.Dialogs</code></td><td>yes</td><td>yes</td><td>base</td><td>—</td></tr>
          <tr><td><code>QtQuick.Effects</code>, <code>QtQuick.Shapes</code>, <code>QtQuick.Particles</code>, <code>QtQuick.VectorImage</code></td><td>yes</td><td>yes</td><td>base</td><td>—</td></tr>
          <tr><td><code>QtCore</code>, <code>QtNetwork</code>, <code>QtQml.Models</code>, <code>Qt.labs.qmlmodels</code>, <code>Qt.labs.folderlistmodel</code></td><td>yes</td><td>yes</td><td>base</td><td>—</td></tr>
          <tr><td><code>QtQuick3D</code>, <code>QtQuick3D.AssetUtils</code></td><td>yes</td><td>yes</td><td><code>qtquick3d</code></td><td>—</td></tr>
          <tr><td><code>QtMultimedia</code></td><td>yes</td><td>yes</td><td><code>qtmultimedia</code></td><td><code>CAMERA</code>, <code>RECORD_AUDIO</code>, <code>MODIFY_AUDIO_SETTINGS</code>, <code>BLUETOOTH</code></td></tr>
          <tr><td><code>QtPositioning</code></td><td>yes</td><td>yes</td><td><code>qtpositioning</code></td><td><code>ACCESS_FINE_LOCATION</code></td></tr>
          <tr><td><code>QtLocation</code></td><td>yes</td><td>yes</td><td><code>qtlocation</code></td><td><code>ACCESS_FINE_LOCATION</code></td></tr>
          <tr><td><code>QtSensors</code></td><td>yes</td><td>yes</td><td><code>qtsensors</code></td><td>—</td></tr>
          <tr><td><code>QtTextToSpeech</code></td><td>yes</td><td>yes</td><td><code>qtspeech</code></td><td><code>MODIFY_AUDIO_SETTINGS</code>, <code>RECORD_AUDIO</code></td></tr>
          <tr><td><code>QtWebView</code></td><td>yes</td><td>yes</td><td><code>qtwebview</code></td><td><code>ACCESS_FINE_LOCATION</code></td></tr>
          <tr><td><code>QtWebSockets</code></td><td>yes</td><td>yes</td><td><code>qtwebsockets</code></td><td>—</td></tr>
          <tr><td><code>QtQuick.VirtualKeyboard</code>, <code>QtQuick.VirtualKeyboard.Settings</code></td><td>yes</td><td>yes</td><td><code>qtvirtualkeyboard</code></td><td>—</td></tr>
          <tr><td><code>Qt.labs.lottieqt</code></td><td>yes</td><td>yes</td><td><code>qtlottie</code></td><td>—</td></tr>
          <tr><td><code>QtQuick.Pdf</code></td><td>yes</td><td><strong>no</strong></td><td><code>qtpdf</code></td><td>—</td></tr>
        </tbody>
      </table>
      <p>The permission column lists what Qt itself adds to the Android manifest when the module ships, taken from the module's own dependency description. Your application still declares the runtime permissions it asks the user for.</p>
      <blockquote>Qt 6.8.3 ships no Android build of Qt PDF, so <code>pdf_view</code> is an iOS-only capability. An Android build that keeps a PDF adapter now fails while configuring, with that reason, instead of installing an application whose PDF screen cannot load.</blockquote>
      <h2>Permissions the application declares</h2>
      <p>Zui exposes each protected capability as a component with a status, so permission handling stays in Ruby. Declaring the capability is still platform work: an Android permission in <code>android/AndroidManifest.xml</code> and an iOS usage description in <code>ios/Info.plist.in</code>, both created for you by <code>zui mobile --enable</code>.</p>
      <table>
        <thead><tr><th>Component</th><th>Android permission</th><th>iOS usage description</th></tr></thead>
        <tbody>
          <tr><td><code>camera_permission</code></td><td><code>CAMERA</code></td><td><code>NSCameraUsageDescription</code></td></tr>
          <tr><td><code>microphone_permission</code></td><td><code>RECORD_AUDIO</code></td><td><code>NSMicrophoneUsageDescription</code></td></tr>
          <tr><td><code>location_permission</code></td><td><code>ACCESS_FINE_LOCATION</code>, <code>ACCESS_COARSE_LOCATION</code></td><td><code>NSLocationWhenInUseUsageDescription</code></td></tr>
          <tr><td><code>contacts_permission</code></td><td><code>READ_CONTACTS</code>, <code>WRITE_CONTACTS</code></td><td><code>NSContactsUsageDescription</code></td></tr>
          <tr><td><code>calendar_permission</code></td><td><code>READ_CALENDAR</code>, <code>WRITE_CALENDAR</code></td><td><code>NSCalendarsUsageDescription</code></td></tr>
          <tr><td><code>bluetooth_permission</code></td><td><code>BLUETOOTH_SCAN</code>, <code>BLUETOOTH_CONNECT</code>, <code>BLUETOOTH_ADVERTISE</code></td><td><code>NSBluetoothAlwaysUsageDescription</code></td></tr>
        </tbody>
      </table>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  state :status, "Waiting for location access"
  state :heading, 0.0

  app :main, title: "Field survey", width: 390, height: 844 do
    safe_area edges: :all, padding: 16 do
      column spacing: 16 do
        label { state.status }

        location_permission(availability: :when_in_use, accuracy: :precise, auto_request: true) do |event|
          state.status = "Location: \#{event.fetch("status")}"
        end

        compass(active: true, data_rate: 10) do |reading|
          state.heading = reading.fetch("azimuth")
        end

        text { "Heading: \#{state.heading.round} degrees" }

        position_source(active: true, update_interval: 2_000) do |position|
          state.status = "\#{position.fetch("latitude").round(4)}, \#{position.fetch("longitude").round(4)}"
        end
      end
    end
  end
end</code></pre>
      <h2>Qt names and Zui names</h2>
      <p>Zui names components for the Ruby API rather than copying Qt, so a search for <code>combo_box</code> finds nothing while <code>dropdown</code> is the component that renders Qt's <code>ComboBox</code>. These are the renamed types in the mobile catalog.</p>
      <table>
        <thead><tr><th>Qt type</th><th>Zui component</th><th>Qt type</th><th>Zui component</th></tr></thead>
        <tbody>
          <tr><td><code>ComboBox</code></td><td><code>dropdown</code></td><td><code>Switch</code></td><td><code>toggle_switch</code></td></tr>
          <tr><td><code>ProgressBar</code></td><td><code>progress</code></td><td><code>ScrollView</code></td><td><code>scroll</code></td></tr>
          <tr><td><code>ToolTip</code></td><td><code>tooltip</code></td><td><code>CheckBox</code></td><td><code>checkbox</code></td></tr>
          <tr><td><code>FileDialog</code></td><td><code>file_picker</code></td><td><code>FolderDialog</code></td><td><code>folder_picker</code></td></tr>
          <tr><td><code>ColorDialog</code></td><td><code>color_picker</code></td><td><code>FontDialog</code></td><td><code>font_picker</code></td></tr>
          <tr><td><code>HorizontalHeaderView</code></td><td><code>horizontal_header</code></td><td><code>VerticalHeaderView</code></td><td><code>vertical_header</code></td></tr>
          <tr><td><code>TapHandler</code></td><td><code>tap_area</code></td><td><code>HoverHandler</code></td><td><code>hover_area</code></td></tr>
          <tr><td><code>DragHandler</code></td><td><code>drag_area</code></td><td><code>PinchHandler</code></td><td><code>pinch_area</code></td></tr>
          <tr><td><code>WheelHandler</code></td><td><code>wheel_area</code></td><td><code>MultiPointTouchArea</code></td><td><code>multi_touch_area</code></td></tr>
          <tr><td><code>InputPanel</code></td><td><code>virtual_keyboard</code></td><td><code>HandwritingInputPanel</code></td><td><code>handwriting_input</code></td></tr>
          <tr><td><code>InputContext</code></td><td><code>keyboard_context</code></td><td><code>VirtualKeyboardSettings</code></td><td><code>keyboard_settings</code></td></tr>
          <tr><td><code>EnterKeyAction</code></td><td><code>keyboard_text_field</code></td><td><code>SystemInformation</code></td><td><code>system_info</code></td></tr>
          <tr><td><code>NetworkInformation</code></td><td><code>network_status</code></td><td><code>VoiceSelector</code></td><td><code>text_to_speech</code></td></tr>
          <tr><td><code>Map</code>, <code>MapView</code>, <code>Plugin</code>, <code>PluginParameter</code></td><td><code>map</code></td><td><code>MapQuickItem</code></td><td><code>map_marker</code></td></tr>
          <tr><td><code>MapCopyrightNotice</code></td><td><code>map_copyright</code></td><td><code>RouteQuery</code></td><td><code>route_model</code></td></tr>
          <tr><td><code>PlaceSearchModel</code></td><td><code>place_search</code></td><td><code>PlaceSearchSuggestionModel</code></td><td><code>place_suggestions</code></td></tr>
          <tr><td><code>CategoryModel</code></td><td><code>place_categories</code></td><td><code>Category</code></td><td><code>place_category</code></td></tr>
          <tr><td><code>Place</code></td><td><code>place_details</code></td><td>the eight <code>Pdf*</code> types</td><td><code>pdf_view</code></td></tr>
        </tbody>
      </table>
      <p>One Zui component often renders several Qt types: <code>pdf_view</code> covers <code>PdfDocument</code>, <code>PdfMultiPageView</code>, <code>PdfPageView</code>, <code>PdfScrollablePageView</code>, <code>PdfPageImage</code>, <code>PdfPageNavigator</code>, <code>PdfSearchModel</code> and <code>PdfSelection</code> behind one Ruby API.</p>
      <h2>Modules nothing imports yet</h2>
      <p>Forty-one further modules ship in both mobile SDKs with no adapter importing them, among them <code>QtCharts</code>, <code>QtGraphs</code>, <code>QtQuick.Timeline</code>, <code>Qt5Compat.GraphicalEffects</code>, <code>QtQml.XmlListModel</code>, <code>QtQuick.LocalStorage</code>, <code>QtScxml</code> and the <code>QtQuick3D</code> submodules. Nothing in the build is missing for them: an adapter that imports one is linked, deployed and permissioned like any other. Zui's charts are drawn with Qt Quick Shapes rather than Qt Charts, which is why that module is unused rather than unavailable.</p>
      <pre data-language="ruby"><code class="language-ruby">require "zui"

Zui.app do
  app :main, title: "Logistics", width: 390, height: 844 do
    column spacing: 0 do
      map plugin: "osm", latitude: 48.8584, longitude: 2.2945, zoom: 14, width: 390, height: 520 do
        map_marker(latitude: 48.8584, longitude: 2.2945) { icon :map_pin, size: 24 }
        map_polyline [{ latitude: 48.8584, longitude: 2.2945 }, { latitude: 48.8738, longitude: 2.2950 }],
          color: "#b7ff5a", width: 4
      end

      card padding: 16, spacing: 8 do
        label "Route briefing", bold: true
        text_to_speech "Two stops remaining on this route", locale: "en_GB", volume: 0.9
      end
    end
  end
end</code></pre>
      <h2>Where the detail lives</h2>
      <p>The framework repository carries the generated reference for all of this: <code>docs/qt-coverage.md</code> lists every Qt module, every type in it and the Zui component that renders it, <code>docs/qt-mobile-modules.md</code> explains how a module reaches a device, and <code>native/qt-modules.json</code> is the registry the build itself reads.</p>
    HTML
  }
]

guides.each do |attributes|
  guide = Guide.find_or_initialize_by(slug: attributes.fetch(:slug))
  guide.assign_attributes(attributes.except(:body))
  guide.body = attributes.fetch(:body)
  guide.save!
end

puts "Seeded #{Guide.count} documentation guides"
