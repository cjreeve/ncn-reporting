class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy]
  before_action :load_issues, only: [:index, :show]
  load_and_authorize_resource

  # GET /issues
  # GET /issues.json
  def index

    options = {}
    exclusion_options = {}
    route_ids = area_ids = nil
    route_ids = params[:route].split('.').collect{ |r| Route.find_by_slug(r).try(:id) } if params[:route]
    area_ids = params[:area].split('.').collect{ |id| id.to_i } if params[:area]
    options[:routes] = {id: route_ids} if params[:route] && params[:route] != "all"
    options[:areas] = {id: area_ids} if params[:area] && params[:area] != "all"
    exclusion_options[:issues] = {state: "closed"} unless params[:state] == "closed"
    @administrative_areas = AdministrativeArea.joins(issues: [:route, :area]).where(options).where.not(exclusion_options).uniq

    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @states = Issue.state_machine.states.collect(&:name) - [:resolved, :unsolvable]
    @labels = Label.all.order(:name)

    @issues_with_coords = @issues.where.not(lat: nil, lng: nil)

    @current_route = Route.find_by_slug(params[:route])
    @current_area = (params[:area].present? && @areas.collect(&:id).include?(params[:area].to_i)) ? Area.find(params[:area].to_i) : nil
    @current_state = (params[:state].present? && @states.include?(params[:state].to_sym)) ? params[:state] : nil
    @current_state = "all states" if params[:state] == "all"
    @current_administrative_area = (params[:region].present? && @administrative_areas.collect(&:id).include?(params[:region].to_i)) ? AdministrativeArea.find(params[:region].to_i) : nil
    if params[:label] == "undefined"
       @current_label = Label.new(name: "undefined")
    elsif params[:label]
      @current_label = Label.find(params[:label])
    end

    respond_to do |format|
      format.html
      format.csv { send_data @issues.to_csv }
      format.gpx { send_data @issues.to_gpx, filename: 'ncn-issue-waypoints.gpx' }
      format.pdf do
        send_data @issues.to_pdf(filter_params(params)), filename: "ncn-issue-report.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end
  end

  # GET /issues/1
  # GET /issues/1.json
  def show
    exclusion_options = {lat: nil, lng: nil}
    exclusion_options[:state] = 'closed' unless params['incl_closed'] == 'true'
    @issues = Issue.where(route: @issue.route, area: @issue.area).order('lng DESC').where.not(exclusion_options)
    @issue_labels_count = @issue.labels.count

    if (current_user && (current_user.is_admin? || current_user.role == "staff" || current_user == @issue.user))
      authorize! :destroy, @issue
    end

    @new_comment = Comment.new

    if @issue.area && @issue.route

      # two searches are added together to allow for any routes none are selected and the area is selected
      # and visa versa
      all_route_section_managers = User.includes(:areas, :routes).where(
        areas: {id: [nil, @issue.area.try(:id)]}, routes: {id: @issue.route.try(:id)}
      ) + User.includes(:areas, :routes).where(
        areas: {id: @issue.area.try(:id)}, routes: {id: [nil, @issue.route.try(:id)]}
      )

      @staff_route_managers = all_route_section_managers.select{ |u| u.role == "staff" }.uniq
      @ranger_route_managers = all_route_section_managers.select{ |u| u.role == "ranger" }.uniq
    else
      @staff_route_managers = @ranger_route_managers = []
    end

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
    # @labels = Label.all.order(:name)
  end

  # GET /issues/1/edit
  def edit
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @categories = Category.all
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
    @issue.images.each { |image| image.url = image.src_identifier if image.src.present? }
    @issue.images.build # << Image.new #unless @issue.images.present?
    @labels = Label.all.order(:name)
    return render filter_params(params, action: 'edit')
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
        format.html { redirect_to issue_path(filter_params(params)), notice: 'Issue was successfully updated.' }
        format.json { render :show, status: :ok, location: @issue }
      else
        @routes = Route.all.order(:name)
        @routes = Route.all.order(:name)
        @areas = Area.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
        @labels = Label.all.order(:name)
        @categories = Category.all
        @problems = {}
        @categories.each { |c| @problems[c.id] = c.problems }
        @issue.images << Image.new unless @issue.images.present? && @issue.images.last.url.present? && @issue.images.last.caption.present?
        format.html { return render filter_params(params, action: 'edit') }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /issues/1
  # DELETE /issues/1.json
  def destroy

    if (current_user && (current_user.is_admin? || current_user.role == "staff" || current_user == @issue.user))
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
    @issue.editor = current_user
    action_taken = nil
    if params[:submit] && @issue.submittable?
      @issue.submit!
      @issue.save
      action_taken = "submitted"
    elsif params[:publish] && @issue.publishable?
      @issue.publish!
      @issue.reported_at = Time.zone.now
      @issue.save
      action_taken = "published"
    elsif params[:start] && @issue.startable?
      @issue.start!
      action_taken = "start"
    elsif params[:resolve] && @issue.closeable?
      @issue.close!
      @issue.resolution = "resolved"
      @issue.completed_at = Time.zone.now
      @issue.save
      action_taken = "resolved"
    elsif params[:reopen] && @issue.reopenable?
      @issue.reopen!
      @issue.save
      action_taken = "reopened"
    elsif params[:reject] && @issue.rejectable?
      @issue.close!
      @issue.resolution = "unsolvable"
      @issue.save
      action_taken = "rejected"
    else
      if (params[:submit] || params[:publish]) && !@issue.submittable? && !@issue.publishable?
        text = "Please provide the following before publishing this issue:  "
        text += " a valid coordinate -" unless @issue.valid_coordinate?
        text += " a route -" unless @issue.route.present?
        text += " a group -" unless @issue.area.present?
        return redirect_to issue_path, alert: text[0..-3]
      else
        return redirect_to issue_path, alert: "Invalid progress request"
      end
    end

    if action_taken.present? && @issue.user != current_user
      UserNotifier.send_issue_state_change_notification(@issue.user, @issue).deliver
    end

    redirect_to issue_path(filter_params(params))
  end


  private

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
      :problem_id, :user_id, :administrative_area_id, :resolution,
      images_attributes: [:id, :url, :src, :caption, :_destroy],
      label_ids: [])
  end

  def load_issues

    options = {}
    exclusions = {}
    joined_options = {}
    include_tables = []
    joined_tables = []
    joined_order = nil

    if %w{csv gpx pdf}.include? params[:format]
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

    if params[:order] == 'category'
      joined_tables << :category
      joined_order = "categories.name #{ direction.to_s }"
    elsif params[:order] == 'route'
      table_name << :route
      joined_order = "routes.name #{ direction.to_s }"
    end

    states = Issue.state_machine.states.collect(&:name)
    route_ids = params[:route].split('.').collect{ |r| Route.find_by_slug(r).try(:id) } if params[:route]
    area_ids = params[:area].split('.').collect{ |id| id.to_i } if params[:area]
    administrative_area_ids = params[:region].split('.').collect{ |id| id.to_i } if params[:region]
    user_ids = params[:user].split('.').collect{ |id| id.to_i } if params[:user]

    if params[:label] == "undefined"
      label_ids = nil
    elsif params[:label]
      label_ids = params[:label].split('.').collect{ |id| id.to_i }
    end

    category_ids = params[:category].split('.').collect{ |id| id.to_i } if params[:category]
    problem_ids = params[:problem].split('.').collect{ |id| id.to_i } if params[:problem]

    options[:category] = category_ids if params[:category]
    options[:problem] = problem_ids if params[:problem]
    options[:route] = route_ids if params[:route] && params[:route] != "all"
    options[:area] = area_ids if params[:area] && params[:area] != "all"
    options[:administrative_area] = administrative_area_ids if params[:region] && params[:region] != "all"
    options[:user] = user_ids if params[:user]
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

    # Issue.includes(:labels).where(labels: {id: nil})

    joined_options[:labels] = {id: label_ids} if params[:label]
    if params[:label]
      # TODO: really need to write some tests for the results.
      include_tables << :labels
      # the following join was added to fix a bug bit it created another bug in that nil label results did not show
      # not sure what the first bug was but may have been fixed now
      # joined_tables << :labels
    end
    joined_tables = nil unless joined_tables.present?

    case params["action"]
    when "index"
      @issues = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order(joined_order).order(order => direction).paginate(page: params[:page], per_page: per_page)
    when "show"
      @next_issue_id = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order('issues.id ASC').where('issues.id > ?', params["id"]).limit(1).first.try(:id)
      @prev_issue_id = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order('issues.id DESC').where('issues.id < ?', params["id"]).limit(1).first.try(:id)
    end
  end
end
