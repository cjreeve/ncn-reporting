class AdministrativeAreasController < ApplicationController
  before_action :set_administrative_area, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  respond_to :html

  def index
    @administrative_areas = AdministrativeArea.all
    respond_with(@administrative_areas)
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

    def administrative_area_params
      params.require(:administrative_area).permit(:name, :short_name)
    end
end
