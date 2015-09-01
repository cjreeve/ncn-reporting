class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  before_action :load_issues, only: [:index, :show]
  load_and_authorize_resource except: [:create]
  # authorize_resource except: [:create, :destroy]

  # GET /issues
  # GET /issues.json
  def index

    @administrative_areas = AdministrativeArea.joins(issues: [:route, :area]).where(
      ((params[:route] && params[:route] != 'all') ? 'routes.slug = ?' : '' ), params[:route]).where(
      ((params[:area] && params[:area] != 'all') ? 'areas.id = ?' : '' ), params[:area]).uniq

    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @states = Issue.state_machine.states.collect(&:name)

    @issues_with_coords = @issues.where.not(lat: nil, lng: nil)

    @current_route = Route.find_by_slug(params[:route])
    @current_area = (params[:area].present? && @areas.collect(&:id).include?(params[:area].to_i)) ? Area.find(params[:area].to_i) : nil
    @current_state = (params[:state].present? && @states.include?(params[:state].to_sym)) ? params[:state] : nil
    @current_state = "all states" if params[:state] == "all"
    @current_administrative_area = (params[:region].present? && @administrative_areas.collect(&:id).include?(params[:region].to_i)) ? AdministrativeArea.find(params[:region].to_i) : nil


    respond_to do |format|
      format.html
      format.csv { send_data @issues.to_csv }
      format.gpx { send_data @issues.to_gpx, filename: 'ncn-issue-waypoints.gpx' }
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @issues = Issue.where(route: @issue.route, area: @issue.area).order('lng DESC')

    if (current_user && (current_user.role == "admin" || current_user.role == "staff" || current_user == @issue.user))
      authorize! :destroy, @issue
    end

    @new_comment = Comment.new
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @issue.images.build
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    # @image = Image.new
    @categories = Category.all
    # @problems = @categories.first.problems
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
  end

  # GET /issues/1/edit
  def edit
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @categories = Category.all
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
    @issue.images.build # << Image.new #unless @issue.images.present?
    return render the_params(params, action: 'edit')
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @categories = Category.all
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }

    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: 'Issue was successfully created.' }
        format.json { render :show, status: :created, location: @issue }
      else
        format.html { render :new }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /issues/1
  # PATCH/PUT /issues/1.json
  def update
    @issue.editor = current_user if current_user
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to issue_path(the_params(params)), notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        @routes = Route.all.order(:name)
        @routes = Route.all.order(:name)
        @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
        @categories = Category.all
        @problems = {}
        @categories.each { |c| @problems[c.id] = c.problems }
        @issue.images << Image.new unless @issue.images.present? && @issue.images.last.url.present? && @issue.images.last.caption.present?
        format.html { return render the_params(params, action: 'edit') }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy

    if (current_user && (current_user.role == "admin" || current_user.role == "staff" || current_user == @issue.user))
      authorize! :destroy, @issue
    end

    @issue.destroy
    respond_to do |format|
      format.html { redirect_to issues_url, notice: 'Issue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def progress
    @issue = Issue.find(params[:id])
    @issue.load_coordinate_string
    @issues = Issue.all.order('lng DESC')
    if params[:publish] && @issue.publishable?
      @issue.publish!
      @issue.reported_at = Time.zone.now
      @issue.save
    elsif params[:resolve] && @issue.resolveable?
      @issue.resolve!
      @issue.completed_at = Time.zone.now
      @issue.save
    elsif params[:close] && @issue.closeable?
      @issue.close!
    elsif params[:reopen] && @issue.reopenable?
      @issue.reopen!
    elsif params[:archive] && @issue.archiveable?
      @issue.archive!
    elsif params[:reject] && @issue.rejectable?
      @issue.reject!
    else
      if params[:publish] && !@issue.publishable?
        text = "Please provide the following before publishing this issue:  "
        text += " a valid coordinate -" unless @issue.valid_coordinate?
        text += " a route -" unless @issue.route.present?
        text += " a group -" unless @issue.area.present?
        return redirect_to issue_path, alert: text[0..-3]
      else
        return redirect_to issue_path, alert: "Invalid progress request"
      end
    end
    redirect_to issue_path(the_params(params))
  end


  private


  def the_params(params, new_params = {})
    the_params = {}
    the_params[:dir] = params[:dir] if params[:dir].present?
    the_params[:order] = params[:order] if params[:order].present?
    the_params[:route] = params[:route] if params[:route].present?
    the_params[:area] = params[:area] if params[:area].present?
    the_params[:state] = params[:state] if params[:state].present?
    the_params[:region] = params[:region] if params[:region].present?
    the_params.merge!(new_params)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_issue
    if params[:issue_number]
      @issue = Issue.find_by(issue_number: params[:issue_number])
    else
      @issue = Issue.find(params[:id])
    end
    @issue.load_coordinate_string
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def issue_params
    params.require(:issue).permit(:issue_number, :title, :description, :priority, :reported_at,
      :completed_at, :location_name, :coordinate, :route_id, :area_id, :url, :category_id, 
      :problem_id, :user_id, :administrative_area_id,
      images_attributes: [:id, :url, :caption, :_destroy])
  end

  def load_issues

    if params[:format] == 'csv' || params[:format] == 'gpx'
      per_page = Issue.count
    else
      per_page = 10
    end

    order = :updated_at
    order = :issue_number if params[:order] == 'number'
    order = :title if params[:order] == 'title'
    order = :problem if params[:order] == 'problem'
    order = :location_name if params[:order] == 'location'
    order = :route if params[:order] == 'route'
    order = :lat if params[:order] == 'lat'
    order = :lng if params[:order] == 'lng'
    order = :updated_at if params[:order] == 'modified'
    order = :state if params[:order] == 'state'
    order = :priority if params[:order] == 'priority'


    if params[:dir] == 'asc'
      direction = :asc
    else
      direction = :desc
    end

    table_name = ''
    if params[:order] == 'category'
      table_name = :category
      order = "categories.name #{ direction.to_s }"
    elsif params[:order] == 'route'
      table_name = :route
      order = "routes.name #{ direction.to_s }"
    end

      

    options = {}
    exclusions = {}
    
    states = Issue.state_machine.states.collect(&:name)
    route = Route.find_by_slug(params[:route])

    options[:route] = route.id if route && params[:route] != "all"
    options[:area] = params[:area].to_i if params[:area].present? && params[:area] != "all"
    options[:administrative_area] = params[:region].to_i if params[:region].present? && params[:region] != "all"
    if params[:state].present? && states.include?(params[:state].to_sym)
      if params[:state] == 'open'
        options[:state] = ['open', 'reopened']
      else
        options[:state] = params[:state]
      end
    else
      exclusions[:state] = ['draft', 'closed', 'archived'] unless params[:state] == "all"
    end

    options[:user_id] = current_user.id if options[:state] == 'draft'

    case params["action"]
    when "index"
      if table_name.present?
        @issues = Issue.joins(table_name).where(options).where.not(exclusions).order(order).paginate(page: params[:page], per_page: per_page)
      else
        @issues = Issue.where(options).where.not(exclusions).order(order => direction).paginate(page: params[:page], per_page: per_page)
      end
    when "show"
      if table_name.present?
        @next_issue_id = Issue.joins(table_name).where(options).where.not(exclusions).order('issues.id ASC').where('issues.id > ?', params["id"]).limit(1).first.try(:id)
        @prev_issue_id = Issue.joins(table_name).where(options).where.not(exclusions).order('issues.id DESC').where('issues.id < ?', params["id"]).limit(1).first.try(:id)
      else
        @next_issue_id = Issue.where(options).where.not(exclusions).order('issues.id ASC').where('issues.id > ?', params["id"]).limit(1).first.try(:id)
        @prev_issue_id = Issue.where(options).where.not(exclusions).order('issues.id DESC').where('issues.id < ?', params["id"]).limit(1).first.try(:id)
      end
    end
  end
end
