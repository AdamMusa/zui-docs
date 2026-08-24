namespace :docs do
  desc "Validate guide syntax, highlighting metadata, and Zui API usage"
  task :validate, [ :source_root ] => :environment do |_task, args|
    source_root = args[:source_root] || Rails.root.join("../zui").to_s
    ruby Rails.root.join("script/validate_guide_examples.rb").to_s, source_root
  end
end
