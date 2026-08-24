class CatalogController < ApplicationController
  def index
    @components = ZuiCatalog.components
    @categories = ZuiCatalog.categories
  end

  def show
    @component = ZuiCatalog.find!(params[:slug])
    @previous_component, @next_component = ZuiCatalog.neighbors(@component)
  end
end
