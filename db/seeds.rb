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
  }
]

guides.each do |attributes|
  guide = Guide.find_or_initialize_by(slug: attributes.fetch(:slug))
  guide.assign_attributes(attributes.except(:body))
  guide.body = attributes.fetch(:body)
  guide.save!
end

puts "Seeded #{Guide.count} documentation guides"
