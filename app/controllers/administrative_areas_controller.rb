class AdministrativeAreasController < ApplicationController
  before_action :set_administrative_area, only: [:show, :edit, :update, :destroy]
  before_action :set_groups, only: [:new, :edit, :update]
  load_and_authorize_resource

  respond_to :html

  def index
    if params[:q]
      @administrative_areas = AdministrativeArea.where("name ilike ?", "%#{params[:q]}%")
    else
      if params[:region] == "all"
        @administrative_areas = AdministrativeArea.all.order(:name)
        @current_region = 'all'
      else
        @current_region = (Region.find_by_id(params[:region] ? params[:region] : current_user.region.id))
        @administrative_areas = AdministrativeArea
          .includes(group: [:region])
          .order([:group_id, :name])
          .select{ |a| a.try(:group).try(:region_id) == @current_region.try(:id) }
      end
      @current_region = 'undefined' if @current_region.nil?
      @regions = Region.all.order(:name)
    end
    respond_to do |format|
      format.html
      format.json { render json: @administrative_areas.collect{ |a| {id: a.id, name: a.short_name }} }
    end
  end

  def show
    respond_with(@administrative_area)
  end

  def new
    @administrative_area = AdministrativeArea.new
    respond_with(@administrative_area)
  end

  def edit
  end

  def create
    @administrative_area = AdministrativeArea.new(administrative_area_params)
    @administrative_area.save
    respond_with(@administrative_area)
  end

  def update
    @administrative_area.update(administrative_area_params)
    respond_with(@administrative_area)
  end

  def destroy
    @administrative_area.destroy
    respond_with(@administrative_area)
  end

  private
    def set_administrative_area
      @administrative_area = AdministrativeArea.find(params[:id])
    end

    def set_groups
      @groups = Group.all.order(:name).sort_by{ |g| g.name.gsub('Other','zzz') }
    end

    def administrative_area_params
      params.require(:administrative_area).permit(:name, :short_name, :group_id)
    end
end
