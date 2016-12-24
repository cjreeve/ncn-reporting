class Admin::UsersController < ApplicationController

  load_and_authorize_resource #except: [:create]

  before_filter :check_read_authorisation
  before_filter :check_manage_authorisation, except: [:index, :show]

  def index
    options = {}

    @regions = Region.all.order(:name)
    @current_region = Region.find_by_id(params[:region].to_i)
    region_ids = params[:region].split('.').collect{ |id| id.to_i } if params[:region]
    options[:region] = region_ids if params[:region] && params[:region] != "all"

    if @current_region
      @groups = Group.where(region: @current_region).order(:name)
      @current_group = Group.find_by_id(params[:group].to_i)
      region_ids = params[:group].split('.').collect{ |id| id.to_i } if params[:group]
      options[:group] = region_ids if params[:group] && params[:group] != "all"
    end


    @users = User.where(options)
                 .where('updated_at is not null')
                 .order("updated_at DESC")
                 .paginate(page: (params[:page] || 1), per_page: 100)

            # TODO - not sure if it is needed to included updated_at: nil accounts
            # they had been tagged at the end but this conflicts with pagination as converts it to an array
            # User.where('updated_at is null')

  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @user.region = current_user.region unless @user.region
    @user.role = "volunteer" unless @user.role.present?
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
    @user.region = current_user.region
    @user.role = "volunteer" unless @user.role.present?
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
    param_keys = [:name, :email, :creator_id, :region_id, :password, :receive_email_notifications, :administrative_area_tokens, image: [:src], route_ids: [], group_ids: [], label_ids: []]
    param_keys += [:role, :is_admin, :is_locked] if current_user.is_admin?
    permitted_params = params.require(:user).permit(param_keys)
  end

  def check_read_authorisation
    unless current_user.is_admin? || current_user.role == "staff"
      redirect_to '/', notice: 'You are not authorised to view that page'
    end
  end

  def check_manage_authorisation
    unless current_user.is_admin?
      redirect_to '/', notice: 'You are not authorised to manage that page'
    end
  end

end
