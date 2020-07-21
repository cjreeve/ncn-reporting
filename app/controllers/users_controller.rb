class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def index
    if params[:q]
      @users = User.active.where("name ilike ?", "%#{params[:q]}%")
    else
      @users = User.active.where(region: @current_region).order("lower(name) ASC")
    end
    respond_to do |format|
      format.html
      format.json { render json: @users.collect{ |u| {id: u.id, name: u.name }} }
    end
  end

  def user_info
    @user = User.find(params[:id])
    render layout: false
  end

  def route_areas
    coords = JSON.parse params[:coords]

    @administrative_areas = []

    coords.each do |coord|
      results = Geocoder.search("#{ coord['lat'] }, #{ coord['lng'] }")
      administrative_area_name = results.present? ? User.get_admin_area(results) : nil
      @administrative_areas << AdministrativeArea.find_or_create_by(name: administrative_area_name) if administrative_area_name.present?

    end

    respond_to do |format|
      format.json { render json:  @administrative_areas.collect{ |a| {id: a.id, name: a.short_name }} }
    end

    # reverse_geocoded_by :latitude, :longitude do |issue, results|
    #   if results.present?
    #     unless issue.location_name.present?
    #       issue.location_name = issue.get_location_name(results)
    #     end

    #     administrative_area_name = issue.get_admin_area(results).strip
    #     administrative_area_name = "unknown" if administrative_area_name.length == 0
    #     issue.administrative_area = AdministrativeArea.find_or_create_by(name: administrative_area_name)
    #     issue.find_group_from_coordinate
    #   end
    # end

  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
