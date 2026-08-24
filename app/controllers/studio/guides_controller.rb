class Studio::GuidesController < ApplicationController
  before_action :ensure_studio_enabled
  before_action :set_guide, only: %i[edit update]

  def index
    @guides = Guide.ordered
  end

  def edit
  end

  def update
    if @guide.update(guide_params)
      redirect_to guide_path(@guide), notice: "#{@guide.title} was published."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_studio_enabled
    return if Rails.env.development? || Rails.env.test? || ENV["ZUI_DOCS_STUDIO"] == "1"

    raise ActionController::RoutingError, "Not Found"
  end

  def set_guide
    @guide = Guide.find_by!(slug: params[:id])
  end

  def guide_params
    params.expect(guide: %i[title summary body])
  end
end
