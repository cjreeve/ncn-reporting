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

    @routes = Route.all.order(:name)
    options = {}
    exclusions = {}
    @states = Issue.state_machine.states.collect(&:name)

    options[:route] = params[:route].to_i if params[:route].present?
    if params[:state].present? && @states.include?(params[:state].to_sym)
      options[:state] = params[:state]
    else
      exclusions[:state] = ['draft', 'closed'] unless params[:state] == "all"
    end
    @issues = Issue.where(options).where.not(exclusions).order(order => direction)
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    @issues = Issue.all.order('lng DESC')
  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @routes = Route.all.order(:name)
  end

  # GET /issues/1/edit
  def edit
    @routes = Route.all.order(:name)
  end

  # POST /issues
  # POST /issues.json
  def create
    @issue = Issue.new(issue_params)

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
      @issue.reported_at = Time.now.in_time_zone('London')
    elsif params[:resolve] && @issue.resolveable?
      @issue.resolve!
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
      @issue.coordinate = "#{@issue.lat}, #{@issue.lng}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def issue_params
      params.require(:issue).permit(:issue_number, :title, :description, :priority, :reported_at,
        :completed_at, :location_name, :coordinate, :route_id)
    end
end
