class GuidesController < ApplicationController
  def show
    @guide = Guide.find_by!(slug: params[:slug])
  end
end
