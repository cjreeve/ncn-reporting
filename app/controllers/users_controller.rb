class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def index
    if params[:q]
      @users = User.where("name ilike ?", "%#{params[:q]}%")
    else
      @users = User.where(region: @current_region, is_locked: false).order("lower(name) ASC")
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

  private

  def set_user
    @user = User.find(params[:id])
  end
end
