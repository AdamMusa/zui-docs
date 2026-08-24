class HomeController < ApplicationController
  def index
    @featured_components = %w[button data_table line_chart shader_effect model_view_3d animation]
      .filter_map { |slug| ZuiCatalog.find(slug) }
    @guides = Guide.ordered
  end
end
