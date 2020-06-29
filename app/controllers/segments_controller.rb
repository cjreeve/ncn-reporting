class SegmentsController < ApplicationController
  before_action :set_segment, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  respond_to :html

  def index
    @segments = Segment.all
  end

  def new
  end

  def show
  end

  def edit
  end

  private

  def set_segment
    @segment = Segment.find(params[:id])
  end

  def segment_params
    params.require(:segment).permit(:name, :route_id, :administrative_area_id, :last_checked_at)
  end
end
