class UsersController < ApplicationController
  load_and_authorize_resource

  def show
  end

  def index
    @users.where.not(role: 'locked').order(:name)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end