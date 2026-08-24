namespace :catalog do
  desc "Refresh the documentation catalog from a Zui source checkout"
  task :sync, [ :source ] do |_task, args|
    source = args[:source] || ENV["ZUI_SOURCE"] || Rails.root.join("../zui").to_s
    ruby Rails.root.join("script/sync_zui_catalog.rb").to_s, source
    ruby Rails.root.join("script/validate_zui_examples.rb").to_s, source
    ZuiCatalog.reset! if defined?(ZuiCatalog)
  end

  desc "Execute every published component example against the Zui Builder"
  task :validate, [ :source ] do |_task, args|
    source = args[:source] || ENV["ZUI_SOURCE"] || Rails.root.join("../zui").to_s
    ruby Rails.root.join("script/validate_zui_examples.rb").to_s, source
  end
end
