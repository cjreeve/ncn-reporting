class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]
  # authorize_resource except: [:create, :destroy]

  # GET /issues
  # GET /issues.json
  def index

    if params[:format] == 'csv' || params[:format] == 'gpx'
      per_page = Issue.count
    else
      per_page = 10
    end

    where_option = ""
    order = :updated_at
    order = :issue_number if params[:order] == 'number'
    order = :title if params[:order] == 'title'
    order = :problem if params[:order] == 'problem'
    order = :location_name if params[:order] == 'location'
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
    end

    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name)
    options = {}
    exclusions = {}
    @states = Issue.state_machine.states.collect(&:name)

    options[:route] = params[:route].to_i if params[:route].present? && params[:route] != "all"
    options[:area] = params[:area].to_i if params[:area].present? && params[:area] != "all"
    options[:administrative_area] = params[:region].to_i if params[:region].present? && params[:region] != "all"
    if params[:state].present? && @states.include?(params[:state].to_sym)
      if params[:state] == 'open'
        options[:state] = ['open', 'reopened']
      else
        options[:state] = params[:state]
      end
    else
      exclusions[:state] = ['draft', 'closed', 'archived'] unless params[:state] == "all"
    end

    options[:user_id] = current_user.id if options[:state] == 'draft'

    @administrative_areas = AdministrativeArea.joins(issues: [:route, :area]).where(
      ((params[:route] && params[:route] != 'all') ? 'routes.id = ?' : '' ), params[:route]).where(
      ((params[:area] && params[:area] != 'all') ? 'areas.id = ?' : '' ), params[:area]).uniq
      #.where(((params[:state] && params[:state] != 'all') ? ' issues.state = ?' : '' ), params[:state])

    if table_name.present?
      @issues = Issue.joins(table_name).where(options).where.not(exclusions).order(order).paginate(page: params[:page], per_page: per_page)
    else
      @issues = Issue.where(options).where.not(exclusions).order(order => direction).paginate(page: params[:page], per_page: per_page)
    end
    @issues_with_coords = @issues.where.not(lat: nil, lng: nil)

    @current_route = (params[:route].present? && @routes.collect(&:id).include?(params[:route].to_i)) ? Route.find(params[:route].to_i) : nil
    @current_area = (params[:area].present? && @areas.collect(&:id).include?(params[:area].to_i)) ? Area.find(params[:area].to_i) : nil
    @current_state = (params[:state].present? && @states.include?(params[:state].to_sym)) ? params[:state] : nil
    @current_state = "all" if params[:state] == "all"
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
    @routes = Route.all.order(:name)
    @areas = Area.all.order(:name)
    @image = Image.new
    @categories = Category.all
    # @problems = @categories.first.problems
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
  end

  # GET /issues/1/edit
  def edit
    @routes = Route.all.order(:name)
    @routes = Route.all.order(:name)
    @areas = Area.all.order(:name)
    @categories = Category.all
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
    @issue.images << Image.new unless @issue.images.present?
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    @routes = Route.all.order(:name)
    @routes = Route.all.order(:name)
    @areas = Area.all.order(:name)
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
    respond_to do |format|
      if @issue.update(issue_params)
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        @routes = Route.all.order(:name)
        @routes = Route.all.order(:name)
        @areas = Area.all.order(:name)
        @categories = Category.all
        @problems = {}
        @categories.each { |c| @problems[c.id] = c.problems }
        @issue.images << Image.new unless @issue.images.present?
        format.html { render :edit }
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
      redirect_to :show, alert: "Invalid progress request"
    end
    redirect_to issue_path
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_issue
      if params[:issue_number]
        @issue = Issue.find_by(issue_number: params[:issue_number])
      else
        @issue = Issue.find(params[:id])
      end
      @issue.coordinate = "#{@issue.lat}, #{@issue.lng}" if @issue.lat && @issue.lng
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:issue_number, :title, :description, :priority, :reported_at,
        :completed_at, :location_name, :coordinate, :route_id, :area_id, :url, :category_id, 
        :problem_id, :user_id, :administrative_area_id,
        images_attributes: [:id, :url, :caption, :_destroy])
    end
end
