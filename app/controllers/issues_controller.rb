class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]

  # GET /issues
  # GET /issues.json
  def index
    where_option = ""
    order = :issue_number
    direction = :desc
    order = :issue_number if params[:order] == 'number'
    order = :title if params[:order] == 'title'
    order = :category if params[:order] == 'category'
    order = :problem if params[:order] == 'problem'
    order = :location if params[:location] == 'number'
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

    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name)
    options = {}
    exclusions = {}
    @states = Issue.state_machine.states.collect(&:name)

    options[:route] = params[:route].to_i if params[:route].present? && params[:route] != "all"
    options[:area] = params[:area].to_i if params[:area].present? && params[:area] != "all"
    if params[:state].present? && @states.include?(params[:state].to_sym)
      options[:state] = params[:state]
    else
      exclusions[:state] = ['draft', 'closed'] unless params[:state] == "all"
    end
    @issues = Issue.where(options).where.not(exclusions).order(order => direction).paginate(page: params[:page], per_page: 6)
    @issues_with_coords = @issues.where.not(lat: nil, lng: nil)

    @current_route = (params[:route].present? && @routes.collect(&:id).include?(params[:route].to_i)) ? Route.find(params[:route].to_i) : nil
    @current_area = (params[:area].present? && @areas.collect(&:id).include?(params[:area].to_i)) ? Area.find(params[:area].to_i) : nil
    @current_state = (params[:state].present? && @states.include?(params[:state].to_sym)) ? params[:state] : nil
    @current_state = "all" if params[:state] == "all"


    # @current_params = the_params(params)
    # binding.pry
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @issues = Issue.all.order('lng DESC')
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
    @image = Image.new
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)
    # binding.pry

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
        format.html { render :edit }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy
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
      @issue.reported_at = DateTime.now.in_time_zone('London')
      @issue.save
    elsif params[:resolve] && @issue.resolveable?
      @issue.resolve!
      @issue.completed_at = DateTime.now.in_time_zone('London')
      @issue.save
    elsif params[:close] && @issue.closeable?
      @issue.close!
    elsif params[:reopen] && @issue.reopenable?
      @issue.reopen!
    elsif params[:archive] && @issue.archiveale?
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
      @issue = Issue.find(params[:id])
      @issue.coordinate = "#{@issue.lat}, #{@issue.lng}" if @issue.lat && @issue.lng
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:issue_number, :title, :description, :priority, :reported_at,
        :completed_at, :location_name, :coordinate, :route_id, :area_id, :url, :category_id, :problem_id,
        images_attributes: [:id, :url, :caption, :_destroy])
    end
end
