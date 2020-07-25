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
    @segments = Segment.where(region: @region).order('last_checked_on IS NOT NULL, last_checked_on ASC')
  end

  def new
    @segment.ranger ||= current_user
    @segment.region ||= current_user.region
  end

  def create
    @sement = Segment.new(segment_params)
    @sement.track = track_from_file if segment_params[:track_file]
    @sement.save
    @segment.valid?
    respond_with @sement
  end

  def show
  end

  def edit
  end

  def update
    @segment.assign_attributes(segment_params)
    @segment.track = track_from_file if segment_params[:track_file]
    @segment.save
    respond_with @segment
  end

  def destroy
    @segment.destroy
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
    @routes = Route.order(:name)
  end

  def set_regions
    @regions = Region.order(:name)
  end

  def set_rangers
    @rangers = User.active.order(:name)
  end

  def track_from_file
    doc = Nokogiri::XML(segment_params[:track_file].tempfile)
    doc.xpath('//xmlns:trkpt').collect do |track_point|
      [track_point.xpath('@lat').to_s.to_f.round(5), track_point.xpath('@lon').to_s.to_f.round(5)]
    end
  end

  def segment_params
    params.require(:segment).permit(:name, :location, :route_id, :administrative_area_id, :region_id, :last_checked_by_id, :last_checked_on, :track_points, :track_file)
  end
end
