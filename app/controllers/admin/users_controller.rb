class Admin::UsersController < ApplicationController

  load_and_authorize_resource except: [:create]

  before_filter :check_authorisation

  def index
    @users = User.all.order(:name)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if user_params[:password].blank?
      the_user_params = user_params.except(:password)
    else
      the_user_params = user_params
    end
    if @user.update(the_user_params)
      redirect_to admin_user_url(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_users_url, notice: 'User account was successfully created'
    else
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    permitted_params = params.require(:user).permit(:name, :email, :password, :role)
  end

  def check_authorisation
    unless current_user.role == "admin"
      redirect_to '/', notice: 'You are not authorised to view that page'
    end
  end

end
