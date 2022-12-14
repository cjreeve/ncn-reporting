class Admin::UsersController < ApplicationController

  load_and_authorize_resource #except: [:create]

  before_action :check_read_authorisation
  before_action :check_manage_authorisation, except: [:index, :show]

  def index
    options = {}
    include_tables = []

    @regions = Region.all.order(:name)
    @current_region = Region.find_by_id(params[:region].to_i)
    region_ids = params[:region].split('.').collect{ |id| id.to_i } if params[:region]
    options[:region] = region_ids if params[:region] && params[:region] != "all"

    if @current_region
      @groups = Group.where(region: @current_region).order(:name)
    end
    if params[:group] && params[:group] != "all"
      if params[:group] == 'none'
        @current_group = 'none'
        options[:groups] = { id: nil }
      else
        @current_group = Group.find_by_id(params[:group].to_i)
        group_ids = params[:group].split('.').collect{ |id| id.to_i }
        options[:groups] = { id: group_ids }
      end
      include_tables << :groups
    end

    @administrative_areas = AdministrativeArea.joins(:issues).limit(10).merge(Issue.order(updated_at: :desc)).to_a.uniq
    if params[:area] && params[:area] != "all"
      if params[:area] == 'none'
        @current_administrative_area = 'none'
        options[:administrative_areas] = { id: nil }
      else
        @current_administrative_area = AdministrativeArea.find_by_id(params[:area].to_i)
        administrative_area_ids = params[:area].split('.').collect{ |id| id.to_i }
        options[:administrative_areas] = { id: administrative_area_ids }
      end
      include_tables << :administrative_areas
    end

    @routes = Route.joins(:issues).merge(Issue.order(updated_at: :desc)).limit(10).to_a.uniq.sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    if params[:route] && params[:route] != "all"
      if params[:route] == 'none'
        @current_route = 'none'
        options[:routes] = { id: nil }
      else
        @current_route = Route.find_by_slug(params[:route])
        route_ids = params[:route].split('.').collect{ |r| Route.find_by_slug(r).try(:id) } if params[:route]
        options[:routes] = { id: route_ids }
      end
      include_tables << :routes
    end

    @roles = User::ROLES
    if params[:role]
      @current_role = User::ROLES.include?(params[:role]) ? params[:role] : 'customised'
      options[:role] = params[:role].split('.')
    end

    options[:is_admin] = true if params[:admin]
    options[:is_locked] = params[:locked].present?


    @users = User.includes(include_tables)
                 .where(options)
                 .where.not(users: { updated_at: nil})

    @users = @users.where("users.name ILIKE ?", "%#{ params[:query] }%") if params[:query].present?

    @users = @users.order(updated_at: :desc)
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
