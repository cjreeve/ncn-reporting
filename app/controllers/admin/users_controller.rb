class Admin::UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
  end

  def edit
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully removed.' }
      format.json { head :no_content }
    end
  end
end
