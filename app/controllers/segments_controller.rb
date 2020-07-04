class SegmentsController < ApplicationController
  before_action :set_segment, only: [:show, :edit, :update, :destroy, :check]
  before_action :set_administrative_areas, only: [:new, :create, :edit, :update]
  before_action :set_routes, only: [:new, :create, :edit, :update]
  before_action :set_regions, only: [:new, :create, :edit, :update, :index]
  before_action :set_rangers, only: [:new, :create, :edit, :update]

  load_and_authorize_resource

  respond_to :html

  def index
    @region = Region.find_by_id(params[:region]) || @current_region || current_user.region
    @segments = Segment.where(region: @region)
  end

  def new
    @segment.ranger ||= current_user
    @segment.region ||= current_user.region
  end

  def create
    @sement = Segment.new(segment_params)
    @sement.save
    @segment.valid?
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

  def check
    if @segment.check!(current_user)
      redirect_to segments_path params.permit(:region)
    else
      render nothing: true
    end
  end

  private

  def set_segment
    @segment = Segment.find(params[:id])
  end

  def set_administrative_areas
    @administrative_areas = AdministrativeArea.order(:name)
  end

  def set_routes
    @routes = Route.all
  end

  def set_regions
    @regions = Region.order(:name)
  end

  def set_rangers
    @rangers = User.active
  end

  def segment_params
    params.require(:segment).permit(:name, :route_id, :administrative_area_id, :region_id, :last_checked_by_id, :last_checked_on, :track_points)
  end
end
