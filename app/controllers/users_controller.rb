class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def index
    @users = User.where(region: @current_region, is_locked: false).order("lower(name) ASC")
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end