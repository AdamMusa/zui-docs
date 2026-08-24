#!/usr/bin/env ruby
# frozen_string_literal: true

require "open3"
require "pathname"
require_relative "../config/environment"

app_root = Pathname.new(__dir__).join("..").expand_path
source_root = Pathname.new(ARGV.fetch(0, ENV.fetch("ZUI_SOURCE", app_root.join("../zui").to_s))).expand_path
$LOAD_PATH.unshift(source_root.join("lib").to_s)
require "zui"

failures = []
block_count = 0

Guide.ordered.find_each do |guide|
  fragment = Nokogiri::HTML5.fragment(guide.body.to_s)
  blocks = fragment.css("pre")
  failures << "#{guide.slug}: guide has no code blocks" if blocks.empty?

  blocks.each_with_index do |pre, index|
    block_count += 1
    location = "#{guide.slug} code block #{index + 1}"
    language = pre["data-language"].to_s
    code_element = pre.at_css("code")
    code = (code_element || pre).text

    failures << "#{location}: missing data-language" if language.empty?
    failures << "#{location}: missing code" if code.strip.empty?
    next if language.empty? || code.strip.empty?

    expected_class = "language-#{language}"
    unless code_element&.classes&.include?(expected_class)
      failures << "#{location}: nested code element must use #{expected_class}"
    end

    case language
    when "ruby"
      begin
        RubyVM::InstructionSequence.compile(code, "guides/#{guide.slug}-#{index + 1}.rb")
        validation_code = code.gsub(/\bZui\.app\b/, "Zui::Application.new")
                              .sub(/\napplication\.run\s*\z/, "\napplication")
        Object.new.instance_eval(validation_code, "guides/#{guide.slug}-#{index + 1}.rb", 1)
      rescue StandardError, SyntaxError => error
        failures << "#{location}: #{error.class}: #{error.message}"
      end
    when "bash"
      _output, error, status = Open3.capture3("bash", "-n", stdin_data: code)
      failures << "#{location}: #{error.strip}" unless status.success?
    else
      failures << "#{location}: unsupported language #{language.inspect}"
    end
  end
end

abort failures.join("\n") if failures.any?

puts "Validated #{block_count} complete guide code blocks"
