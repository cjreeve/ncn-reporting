class SegmentsController < ApplicationController
  before_action :set_segment, only: [:show, :edit, :update, :destroy]
  before_action :set_administrative_areas, only: [:new, :edit, :update]
  before_action :set_routes, only: [:new, :edit, :update]
  before_action :set_rangers, only: [:new, :edit, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @segments = Segment.all
  end

  def new
    @segment.ranger ||= current_user
  end

  def create
    @sement = Segment.new(segment_params)
    @sement.save
    respond_with(@sement)
  end

  def show
  end

  def edit
    @rangers = User.active
  end

  def update
    @segment.update(segment_params)
    respond_with @segment
  end

  private

  def set_segment
    @segment = Segment.find(params[:id])
  end

  def set_administrative_areas
    @administrative_areas = AdministrativeArea.all
  end

  def set_routes
    @routes = Route.all
  end

  def set_rangers
    @rangers = User.active
  end

  def segment_params
    params.require(:segment).permit(:name, :route_id, :administrative_area_id, :last_checked_by_id, :last_checked_on, :track_points)
  end
end
