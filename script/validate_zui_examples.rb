#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

app_root = Pathname.new(__dir__).join("..").expand_path
source_root = Pathname.new(ARGV.fetch(0, ENV.fetch("ZUI_SOURCE", app_root.join("../zui").to_s))).expand_path
$LOAD_PATH.unshift(source_root.join("lib").to_s)
require "zui"

catalog = JSON.parse(app_root.join("config/zui_catalog.json").read)
failures = []

catalog.fetch("components").each do |component|
  slug = component.fetch("slug")
  example = component.fetch("example")

  unless example.match?(/\b#{Regexp.escape(slug)}(?:\s|\()/)
    failures << "#{slug}: snippet does not call ##{slug}"
    next
  end

  begin
    Zui::Application.new do
      app :example do
        instance_eval(example, "catalog/#{slug}.rb", 1)
      end
    end
  rescue StandardError, SyntaxError => error
    failures << "#{slug}: #{error.class}: #{error.message}"
  end
end

abort failures.join("\n") if failures.any?

puts "Validated #{catalog.fetch("components").length} Zui Builder examples"
