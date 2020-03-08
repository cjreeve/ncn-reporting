class IssuesController < ApplicationController
  before_action :set_issue, only: [:show, :edit, :update, :destroy, :follow, :unfollow]
  before_action :load_issues, only: [:index, :show]
  # before_action :load_issue_followers, only: [:show, :create]
  load_and_authorize_resource

  # GET /issues
  # GET /issues.json
  def index

    options = {}
    exclusion_options = {}
    route_ids = group_ids = nil
    route_ids = params[:route].split('.').collect{ |r| Route.find_by_slug(r).try(:id) } if params[:route]
    group_ids = params[:group].split('.').collect{ |id| id.to_i } if params[:group] && params[:group] != "-1"
    area_ids = params[:area].split('.').collect{ |id| id.to_i } if params[:area]
    options[:routes] = {id: route_ids} if params[:route] && params[:route] != "all"
    options[:groups] = {id: group_ids} if params[:group] && params[:group] != "all" && params[:group] != "-1"
    options[:administrative_areas] = {id: area_ids} if params[:area]
    exclusion_options[:issues] = {state: "closed"} unless params[:state] == "closed"
    @administrative_areas = AdministrativeArea.joins(issues: [:route, :group]).where(options).where.not(exclusion_options).order(:short_name).limit(11).distinct

    @groups = Group.joins(:issues).where(region: @current_region).distinct.order(:name)
    @current_group = (@current_region.group_ids.include?(params[:group].to_i) ? Group.find_by_id(params[:group].to_i) : nil)

    @routes = Route.joins(issues: [:group, :administrative_area]).where(options).distinct.order(:name).limit(11).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @current_route ||= Route.find_by_slug(params[:route])

    @states = Issue.state_machine.states.collect(&:name) - [:resolved, :unsolvable]
    @labels = Label.all.order(:name)

    @issues_with_coords = @issues.where.not(lat: nil, lng: nil)

    @current_state = (params[:state].present? && @states.include?(params[:state].to_sym)) ? params[:state] : nil
    @current_state = "all states" if params[:state] == "all"
    @current_administrative_area = AdministrativeArea.find_by_id(params[:area]) unless (params[:area] && params[:area].include?('.'))
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
    exclusion_options[:state] = 'closed' if params['excl_closed'] == 'true'
    near_range = 0.03
    @issues = Issue.where(
      lat: (@issue.lat.to_f-near_range)..(@issue.lat.to_f+near_range),
      lng: (@issue.lng.to_f-near_range)..(@issue.lng.to_f+near_range)
    ).order('lng DESC').where.not(exclusion_options)
    @issue_labels_count = @issue.labels.count
    @labels = Label.all.order(:name)
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @groups = Group.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }

    # TODO - use geocoder gem for this
    near_range = 0.0004
    @duplicate_issues = Issue.joins(:category).joins(:problem).where(
      category: @issue.category,
      problem: @issue.problem,
      lat: (@issue.lat.to_f-near_range)..(@issue.lat.to_f+near_range),
      lng: (@issue.lng.to_f-near_range)..(@issue.lng.to_f+near_range)).where.not(id: [@issue] + @issue.twinned_issues)

    @nearby_issues = Issue.where(
      lat: (@issue.lat.to_f-near_range)..(@issue.lat.to_f+near_range),
      lng: (@issue.lng.to_f-near_range)..(@issue.lng.to_f+near_range)).where.not(id: [@issue.id]+@duplicate_issues.collect(&:id))

    if (current_user && (current_user.is_admin? || current_user.role == "staff" || current_user == @issue.user))
      authorize! :destroy, @issue
    end

    per_page = Rails.application.config.comments_per_page
    @comments = @issue.comments.order(created_at: :desc).paginate(page: 1, per_page: per_page)
    @new_comment = Comment.new
    @last_comment = @comments.first
    @image_ids = @issue.image_ids

    if @issue.administrative_area && @issue.route
      all_route_section_managers = @issue.route_section_managers
      @staff_route_managers = (all_route_section_managers.select{ |u| u.role == "staff" } + User.joins(:groups).where(role: 'staff', groups: { id: @issue.group})).uniq
      @ranger_route_managers = all_route_section_managers.select{ |u| u.role == "ranger" }.uniq
      @coordinator_route_managers = load_coordinator_route_managers(@issue)
    else
      @staff_route_managers = @ranger_route_managers = []
    end

  end

  # GET /issues/new
  def new
    @issue = Issue.new
    @issue.images.build
    @issue.coordinate = params[:c]
    @routes = Route.all.order(:name).sort_by{ |r| r.name.gsub('Other','999').gsub(/[^0-9 ]/i, '').to_i }
    @groups = Group.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
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
    @groups = Group.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
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
    @groups = Group.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
    @categories = Category.all
    @problems = {}
    @categories.each { |c| @problems[c.id] = c.problems }
    flash[:uniqueness_properties_changed] = uniqueness_properties_changed?(@issue)

    respond_to do |format|
      if @issue.save

        @issue = set_issue_followers(@issue, @issue.route_section_managers)
        @issue.save

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
    old_label_names = @issue.labels.collect(&:name)
    @issue.assign_attributes(issue_params)
    flash[:uniqueness_properties_changed] = uniqueness_properties_changed?(@issue)

    if notifiable_properties_changed?(@issue)
      @issue = set_issue_followers(@issue, @issue.route_section_managers)
    elsif !old_label_names.include?("sustrans") && @issue.labels.collect(&:name).include?("sustrans")
      @issue.followers << @issue.route_section_managers.select{ |u| u.role == "staff" }
      @issue.followers.uniq!
    end

    respond_to do |format|
      if @issue.save
        format.html { redirect_to issue_number_path2(@issue, params), notice: 'Issue was successfully updated.' }
        format.js { return render :followers }
        format.json { render :show, status: :ok, location: @issue }
      else
        @routes = Route.all.order(:name)
        @routes = Route.all.order(:name)
        @groups = Group.all.order(:name).sort_by{ |a| a.name.gsub('Other','zzz') }
        @labels = Label.all.order(:name)
        @categories = Category.all
        @problems = {}
        @categories.each { |c| @problems[c.id] = c.problems }
        @issue.images << Image.new unless @issue.images.present? && @issue.images.last.url.present? && @issue.images.last.caption.present?
        format.html { return render filter_params(params, action: 'edit') }
        format.js { return render :followers }
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

  def follow
    if @issue.followers.include?(current_user)
      flash[:alert] = "You are already following this issue"
    else
      if @issue.followers << current_user
        flash[:alert] = "You are now following this issue"
      else
        flash[:alert] = "Sorry it didn't work. Please try again."
      end
    end
    redirect_to issue_number_path(issue_number: @issue.issue_number)
  end

  def unfollow
    if @issue.followers.include?(current_user)
      if IssueFollowerSelection.find_by(user_id: current_user, issue_id: @issue).try(:destroy)
        flash[:alert] = "You are no longer following this issue"
      else
        flash[:alert] = "Sorry it didn't work. Please try again."
      end
    else
      flash[:alert] = "You are not following this issue"
    end
    redirect_to issue_number_path(issue_number: @issue.issue_number)
  end

  def search
    @issues_with_coords = []

    if params[:q]
      near_range = 0.03
      min_lng, max_lng = Rails.application.config.coord_limits[:lng]
      min_lat, max_lat = Rails.application.config.coord_limits[:lat]

      @lat, @lng = params[:q].split(",").collect{ |c| c.to_f }

      # search for if not a valid coordinate
      unless @lng && @lat && (@lng > min_lng && @lng < max_lng) && (@lat > min_lat &&  @lat < max_lat)
        # results = Geocoder.search("Greenwich, London")
        # results.first.data["geometry"]["location"]["lat"]
        l = Location.find_or_create_by(id: 1)
        l.address = params[:q]
        l.save
        @lng = l.longitude
        @lat = l.latitude
      end

      @issues_with_coords = Issue.where(
        lat: (@lat-near_range)..(@lat+near_range),
        lng: (@lng-near_range)..(@lng+near_range)
      )
    end
  end

  def uniqueness_properties_changed?(issue)
    issue.id_changed? || issue.category_id_changed? || issue.problem_id_changed? || (issue.coordinate != "#{ issue.lat }, #{ issue.lng }")
  end

  def toggle_twins
    @issue = Issue.find(params[:id])
    @twin_issue = Issue.find(params[:twin_id])
    if @issue && @twin_issue
      if @issue.twinned_issues.include?(@twin_issue)
        @issue.twinned_issues -= [@twin_issue]
      else
        @issue.twinned_issues += [@twin_issue]
      end
      @issue.save
      redirect_to issue_number_path2(@issue, params)
    else
      flash[:alert] = "issue could not be found"
      redirect_to issue_number_path2(@issue, params)
    end
  end

  def progress
    @issue = Issue.find(params[:id])
    @issues = Issue.all.order('lng DESC')
    @issue.editor = current_user
    @issue.followers << current_user
    action_taken = nil
    if params[:submit] && @issue.submittable?
      @issue.submit!
      @issue.save
      action_taken = "submitted"
      @issue.send_issue_creation_notifications(:submit, current_user)
    elsif params[:respecify]
      @issue.respecify!
      @issue.save
      action_taken = "respecified"
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
        values = []
        values << "a valid coordinate" unless @issue.valid_coordinate?
        values << "a route" unless @issue.route.present?
        values << " label(s)" unless (@issue.labels.present? || current_user.role == 'volunteer')
        text += values.to_sentence
        return redirect_to  issue_number_path2(@issue, params), alert: text
      else
        return redirect_to issue_number_path2(@issue, params), alert: "Invalid progress request"
      end
    end

    if action_taken.present? && @issue.user != current_user
      UserNotifier.send_issue_state_change_notification(@issue.user, @issue).deliver
    end

    redirect_to issue_number_path2(@issue, params)
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_issue
    if params[:issue_number]
      @issue = Issue.find_by(issue_number: params[:issue_number])
    else
      @issue = Issue.find(params[:id])
    end
    return redirect_to '/404' unless @issue
    @issue.load_coordinate_string
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def issue_params
    params.require(:issue).permit(:issue_number, :title, :description, :priority, :reported_at,
      :completed_at, :location_name, :coordinate, :route_id, :group_id, :url, :category_id,
      :problem_id, :user_id, :administrative_area_id, :resolution, :user_tokens,
      images_attributes: [:id, :url, :src, :caption, :rotation, :taken_on, :_destroy],
      label_ids: [], follower_ids: [])
  end

  def load_issues
    return unless current_user

    options = {}
    exclusions = {}
    joined_options = {}
    include_tables = []
    joined_tables = []
    joined_order = nil

    # set the user issue filter mode preference
    if %w(national regional customised).include?(params[:mode]) && params[:mode] != current_user.issue_filter_mode
      current_user.update_attributes(issue_filter_mode: params[:mode])
    end

    if current_user.issue_filter_mode == 'regional'
      params['region'] = current_user.region.id
      include_tables << :group
      joined_options[:groups] = { region_id: current_user.region.id }
    elsif current_user.issue_filter_mode == 'customised'
      params[:route] = current_user.routes.collect(&:slug).join('.') if current_user.routes.present? && params[:route].blank?
      if current_user.administrative_areas.present?
        params[:area] = current_user.administrative_areas.collect(&:id).join('.') if params[:area].blank?
      elsif current_user.groups.present?
        params[:group] = current_user.groups.collect(&:id).join('.')
      end
    end

    if %w{csv gpx pdf}.include? params[:format]
      per_page = Issue.count
    else
      per_page = params[:per_page] || 10
    end

    @regions = Region.all.order(:name)
    @current_region = (params[:region] ? Region.find_by_id(params[:region].to_i) : current_user.region)

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

    if params[:order] == 'category'
      joined_tables << :category
      joined_order = "categories.name #{ direction.to_s }"
    elsif params[:order] == 'route'
      joined_tables << :route
      joined_order = "routes.name #{ direction.to_s }"
    end

    states = Issue.state_machine.states.collect(&:name)
    route_ids = params[:route].split('.').collect{ |r| Route.find_by_slug(r).try(:id) } if params[:route]
    group_ids = params[:group].split('.').collect{ |id| id.to_i } if params[:group]
    administrative_area_ids = params[:area].split('.').collect{ |id| id.to_i } if params[:area]
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
    options[:group] = group_ids if params[:group] && params[:group] != "all"
    options[:group] = nil if params[:group] == "-1"
    options[:administrative_area] = administrative_area_ids if params[:area] && params[:area] != "all"
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
      # binding.pry
      @issues = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order(joined_order).order(order => direction).paginate(page: params[:page], per_page: per_page)
    when "show"
      @next_issue_id = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order('issues.issue_number ASC').where('issues.issue_number > ?', params["issue_number"]).limit(1).first.try(:issue_number)
      @prev_issue_id = Issue.joins(joined_tables).includes(include_tables).where(options).where(joined_options).where.not(exclusions).order('issues.issue_number DESC').where('issues.issue_number < ?', params["issue_number"]).limit(1).first.try(:issue_number)
    end
  end

  # replaced by Issue.route_section_managers
  # def load_all_route_section_managers(issue)
  #   # two searches are added together to allow for any routes none are selected and the administrative_area is selected
  #   # and visa versa
  #   User.includes(:administrative_areas, :routes)
  #       .where(
  #         administrative_areas: {id: [nil, issue.administrative_area.try(:id)]},
  #         routes: {id: issue.route.try(:id)}) +
  #   User.includes(:administrative_areas, :routes)
  #       .where(
  #         administrative_areas: {id: issue.administrative_area.try(:id)},
  #         routes: {id: [nil, issue.route.try(:id)]})
  # end

  def load_coordinator_route_managers(issue)
    User.includes(:groups)
        .where( groups: {id: issue.group.try(:id)})
        .where(role: "coordinator")
  end


  def set_issue_followers(issue, all_route_section_managers)
    followers = all_route_section_managers.select{ |u| u.role == "ranger" }
    if issue.priority == 3 || issue.labels.collect(&:name).include?('sustrans')
      followers += all_route_section_managers.select{ |u| u.role == "staff" }
      followers += load_coordinator_route_managers(issue)
    end
    unless followers.present?
      followers += load_coordinator_route_managers(issue)
    end

    # TODO - disabled this because too many issues being assigned to all staff. Need it to be more specific.
    # if followers.blank? && issue.lat.present? && issue.lng.present?
    #   followers += all_route_section_managers.select{ |u| u.role == "staff" }
    # end

    followers << current_user
    issue.followers += followers.uniq
    issue.followers = issue.followers.uniq
    issue
  end

  def notifiable_properties_changed?(issue)
    issue.id_changed? ||
      issue.administrative_area_id_changed? ||
      issue.route_id_changed? ||
      (issue.priority_changed? && issue.priority == 3) ||
      (issue.problem_id_changed? && issue.problem.try(:default_priority) == 3)
  end
end
