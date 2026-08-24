require "json"

class ZuiCatalog
  DATA_PATH = Rails.root.join("config/zui_catalog.json")

  class << self
    def metadata = data.fetch("metadata")
    def categories = data.fetch("categories")
    def components = data.fetch("components")

    def find(slug)
      component_index[slug.to_s]
    end

    def find!(slug)
      find(slug) || raise(ActiveRecord::RecordNotFound, "Unknown Zui component: #{slug}")
    end

    def neighbors(component)
      index = components.index { |candidate| candidate.fetch("slug") == component.fetch("slug") }
      [ index&.positive? ? components[index - 1] : nil, index && index < components.length - 1 ? components[index + 1] : nil ]
    end

    def reset!
      @data = @component_index = nil
    end

    private

    def data
      @data ||= JSON.parse(DATA_PATH.read)
    end

    def component_index
      @component_index ||= components.index_by { |component| component.fetch("slug") }
    end
  end
end
