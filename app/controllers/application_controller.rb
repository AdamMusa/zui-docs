class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_navigation

  private

  def set_navigation
    @catalog_categories = ZuiCatalog.categories
    @navigation_guides = Guide.ordered.select(:title, :slug)
  rescue ActiveRecord::StatementInvalid
    @navigation_guides = []
  end
end
