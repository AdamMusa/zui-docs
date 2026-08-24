class SearchController < ApplicationController
  MAX_RESULTS = 12

  def index
    query = params.fetch(:q, "").to_s.strip.downcase.first(100)
    terms = query.split(/\s+/)

    entries = component_entries + guide_entries
    entries.select! { |entry| terms.all? { |term| entry.fetch(:search_text).include?(term) } } if terms.any?
    entries.sort_by! { |entry| [ -score(entry, query), entry.fetch(:label) ] }

    render json: entries.first(MAX_RESULTS).map { |entry| entry.except(:search_text) }
  end

  private

  def component_entries
    ZuiCatalog.components.map do |component|
      {
        label: component.fetch("title"),
        meta: component.fetch("category"),
        path: component_path(component.fetch("slug")),
        search_text: component.fetch("search_text")
      }
    end
  end

  def guide_entries
    Guide.ordered.map do |guide|
      {
        label: guide.title,
        meta: "Guide",
        path: guide_path(guide),
        search_text: "guide #{guide.title} #{guide.summary}".downcase
      }
    end
  end

  def score(entry, query)
    label = entry.fetch(:label).downcase
    return 0 if query.empty?
    return 100 if label == query
    return 50 if label.start_with?(query)
    return 20 if label.include?(query)

    1
  end
end
