class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def index
    @users = User.where.not(role: 'locked').order("lower(name) ASC")
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end