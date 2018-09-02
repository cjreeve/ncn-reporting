class Issue < ActiveRecord::Base
  attr_accessor :coordinate

  require "open-uri"

  include Geocodeable

  belongs_to :route
  belongs_to :group
  belongs_to :administrative_area
  has_many :images, as: :owner, dependent: :destroy
  has_many :comments
  has_many :issue_label_selections
  has_many :labels, through: :issue_label_selections
  has_many :twins
  has_many :twinned_issues, through: :twins, dependent: :destroy
  has_many :issue_follower_selections, dependent: :destroy
  has_many :followers, -> { uniq }, through: :issue_follower_selections, source: :user
  belongs_to :category
  belongs_to :problem
  belongs_to :user
  belongs_to :editor, class_name: "User"

  attr_reader :user_tokens

  def user_tokens=(ids)
    self.follower_ids = ids.split(",")
  end

  accepts_nested_attributes_for(
    :images,
    allow_destroy: true,
    reject_if:  proc { |a|
      a[:id].blank? && a[:url].blank? && a[:src].blank? && a[:caption].blank?
    }
  )

  PRIORITY = {
    1 => 'low',
    2 => 'medium',
    3 => 'high'
  }

  PRIORITY_CHANGED = false

  before_validation :load_coordinate_string
  before_validation :set_issue_number
  before_validation :set_priority
  before_validation :set_title
  before_validation :set_edited_at
  after_update :send_high_priority_issue_notifications_if_changed

  validates :title, length: { in: 2..30, message: '- the problem must be defined'}
  validates :url, length: { in: 0..1000, message: '- the url must be less than 1000 characters'}

  after_validation :coordinate_to_latlng

  unless Rails.env.test?
    geocoded_by :address, latitude: :lat, longitude: :lng

    reverse_geocoded_by :latitude, :longitude do |issue, results|
      if results.present?
        unless issue.location_name.present?
          issue.location_name = issue.get_location_name(results)
        end

        administrative_area_name = issue.get_admin_area(results).strip
        administrative_area_name = "unknown" if administrative_area_name.length == 0
        issue.administrative_area = AdministrativeArea.find_or_create_by(name: administrative_area_name)
        issue.find_group_from_coordinate
      end
    end

    after_validation :reverse_geocode, if: :lat_or_lng_changed?
  end

  state_machine :state, initial: :draft do
    event :submit do
      transition draft: :submitted
    end
    event :respecify do
      transition submitted: :draft
    end
    event :publish do
      transition submitted: :open
    end
    event :start do
      transition [:open, :reopened] => :in_progress
    end
    event :resolve do
      transition [:open, :reopened, :in_progress] => :closed
    end
    event :reject do
      transition [:open, :reopened, :in_progress] => :closed
    end
    event :close do
      transition [:open, :reopened, :in_progress, :resolved, :unsolvable] => :closed
    end
    event :reopen do
      transition [:unsolvable, :resolved, :closed] => :reopened
    end
  end

  def submittable?
    self.valid_coordinate? &&
    self.route.present? &&
    self.state_events.include?(:submit)
  end

  def respecifyable?
    self.state_events.include?(:respecify)
  end

  def publishable?
    self.valid_coordinate? &&
    self.route.present? &&
    self.labels.present?
  end

  def startable?
    self.state_events.include?(:start)
  end

  def openable?
    self.state_events.include?(:open)
  end

  def reopenable?
    self.state_events.include?(:reopen)
  end

  def closeable?
    self.state_events.include?(:close)
  end

  def rejectable?
    self.state_events.include?(:reject)
  end

  def resolveable?
    self.state_events.include?(:resolve)
  end

  def archiveable?
    self.state_events.include?(:archive)
  end

  def load_coordinate_string
    if self.lat && self.lng && !self.coordinate
      self.coordinate = "#{self.lat.round(5)}, #{self.lng.round(5)}"
    end
  end

  def valid_coordinate?
    min_lng, max_lng = Rails.application.config.coord_limits[:lng]
    min_lat, max_lat = Rails.application.config.coord_limits[:lat]
    self.lng.present? && (self.lng > min_lng && self.lng < max_lng) &&
    self.lat.present? && (self.lat > min_lat &&  self.lat < max_lat)
  end

  def active_followers
    followers.active
  end

  def status
    return self.resolution if self.state == 'closed'
    I18n.t('state.'+self.state)
  end

  def the_problem
    if self.problem
      self.problem.name
    else
      self.title
    end
  end

  def the_editor
    if self.editor
      editor = self.editor
    elsif self.user
      editor = self.user
    else
      User.new(name: '(unknown)')
    end
  end

  def the_summary
    self.issue_number.to_s + '-' + self.category.name.to_s[0..3] + '-' + the_problem.to_s[0..14]  + " - #{ self.status }"
  end

  def latitude
    self.lat
  end

  def longitude
    self.lng
  end

  def find_group_from_coordinate
    if self.administrative_area.group.present?
      self.group = self.administrative_area.group
    else
      self.group = nil
    end
  end

  def send_issue_creation_notifications(event_type, current_user)
    self.followers.each do |user|
      UserNotifier.send_issue_creation_notification(self, user, event_type).deliver unless user == current_user
    end
  end

  def route_section_managers
    # two searches are added together to allow for any routes none are selected and the administrative_area is selected
    # and visa versa
    User.includes(:administrative_areas, :routes).where(administrative_areas: {id: [nil, self.administrative_area.try(:id)]}, routes: {id: self.route.try(:id)}).uniq +
    User.includes(:groups, :routes).
         where(groups: {id: self.group.try(:id)}, routes: {id: [nil, self.route.try(:id)]}).uniq
  end

  # def route_section_managers
  #   User.joins(:administrative_areas, :routes).
  #        where(administrative_areas: {id: [nil, self.administrative_area.try(:id)]}, routes: {id: self.route.try(:id)}).
  #        union(User.joins(:groups, :routes).where(groups: {id: self.group.try(:id)}, routes: {id: [nil, self.route.try(:id)]})).
  #        uniq
  # end

  def staff_section_managers
    self.route_section_managers.select{ |u| u.role == "staff" }.uniq
  end

  def ranger_section_managers
    self.route_section_managers.select{ |u| u.role == "ranger" }.uniq
  end

  def ranger_and_staff_section_managers
    self.route_section_managers.select{ |u| %w(ranger staff).include?(u.role)}.uniq
  end

  private

  def lat_or_lng_changed?
    self.lat_changed? || self.lng_changed?
  end

  def set_edited_at
    self.edited_at = Time.zone.now
  end

  def set_issue_number
    self.issue_number = Issue.last.try(:issue_number).to_i + 1 unless self.issue_number.present?
  end

  def coordinate_to_latlng
    if self.coordinate.present?
      if self.coordinate.include?('openstreetmap.org/')
        query = URI(self.coordinate).query
        query_params = CGI::parse(query)
        self.lat = query_params["mlat"].first.to_f
        self.lng = query_params["mlon"].first.to_f
      else
        coordinate = self.coordinate.split('geo:').last.split('?').first
        self.lat = coordinate.split(/[\s,]+/)[0].to_f.round(5)
        self.lng = coordinate.split(/[\s,]+/)[1].to_f.round(5)
      end
    else
      self.lat = nil
      self.lng = nil
    end
  end

  def set_priority
    if (problem_id.present? && priority.blank?) || (problem_id.present? && problem_id_changed?)
      self.priority = Problem.find(self.problem_id).default_priority
    end
  end

  def send_high_priority_issue_notifications_if_changed
    if self.priority_changed? && PRIORITY[priority] == 'high' && %w{submitted open reopened}.include?(self.state)
      self.send_issue_creation_notifications(:change, self.editor)
    end
  end

  def set_title
    problem = Problem.find(self.problem_id) if self.problem_id
    self.title = problem.name unless (problem.nil? || problem.name == 'other')
  end

  def self.to_csv
    CSV.generate do |csv|
      # csv << column_names
      csv << ["number",
       "category",
       "problem",
       "status",
       "route",
       "group",
       "location",
       "latitude",
       "longitude",
       "description",
       "url",
       "priority",
       "date reported",
       "date completed"]

      all.each do |issue|
        issue_values = []
        issue_values << issue.issue_number
        issue_values << issue.category.name
        issue_values << issue.title
        issue_values << issue.state
        issue_values << (issue.route ? issue.route.name : '')
        issue_values << (issue.group ? issue.group.name : '')
        issue_values << (issue.location_name ? issue.location_name : '')
        issue_values << (issue.lat ? issue.lat : '')
        issue_values << (issue.lng ? issue.lng : '')
        issue_values << (issue.description ? issue.description : '')
        issue_values << (issue.url ? issue.url : '')
        issue_values << (issue.priority ? issue.priority : '')
        issue_values << (issue.reported_at ? issue.reported_at.strftime("%d/%m/%Y") : '')
        issue_values << (issue.completed_at ? issue.completed_at.strftime("%d/%m/%Y") : '')
        # csv << issue.attributes.values_at(*column_names)
        csv << issue_values
      end
    end
  end


  def self.to_gpx
    gpx = GPX::GPXFile.new
    all.each do |stop|
      gpx.waypoints << GPX::Waypoint.new({name: stop.the_summary , lat: stop.lat, lon: stop.lng, time: stop.created_at})
    end
    gpx.to_s
  end

  def self.to_pdf(params)

    p = Prawn::Document.new
    filters = []
    # p.stroke_axis
    # p.stroke_circle [0, 0], 10
    # pdf.blank_line
    p.font_size(24)
    p.text "NCN Issues Report", align: :center
    p.font_size(10);
    p.text "#{ Time.now.strftime('%d %B %Y') }", align: :center
    p.move_down(30)

    p.font_size(12);
    if params.present?

      filters << ["route", Route.find_by_slug(params[:route]).try(:name)] if params[:route]
      p.text "#{ filters.collect{ |f| f[1] }.join('  -  ') }", align: :center
    else
      p.text "Summary of all outstanding issues", align: :center
    end
    p.move_down(10);

    n_issues = all.count
    issue_index = 0

    all.group_by(&:administrative_area_id).each do |area_id, area_issues|
      area_issues.each  do |issue|

        p.text "#{ issue.administrative_area.try(:name) }", align: :center
        p.move_down(20);

        p.font_size(18);
        p.text "(#{ issue.issue_number }) #{ '- ' + issue.try(:route).try(:name).to_s unless params[:route] } - #{ issue.try(:category).try(:name) }: #{ issue.try(:problem).try(:name) }"

        p.font_size(12);
        if issue.reported_at
          p.text "#{ issue.reported_at.strftime('%d %b %Y') }", align: :right
        end

        p.font_size(8)
        p.text "location: #{ issue.location_name }, coordinate: #{ issue.lat }, #{ issue.lng }, state: #{ I18n.t 'state.' + issue.state }"

        begin
          p.image open("https://maps.googleapis.com/maps/api/staticmap?center=#{ issue.lat },#{ issue.lng }&zoom=16&size=640x150&maptype=terrain&markers=color:blue%7C#{ issue.lat },#{ issue.lng }&key=#{ Rails.application.config.google_api_key }"), width: 540
        rescue
          p.text 'map could not be displayed'
        end

        p.move_down(15)
        p.font_size(12)
        p.text "<b>Description:</b> #{ issue.description.present? ? ApplicationController.helpers.render_markdown(issue.description, 'restricted') : 'none' }", inline_format: true


        p.font_size(11)
        p.font "Times-Roman"
        if issue.images.present? # && issue.images.first.fetch_remote_image.present?

          t = p.make_table(
            prawn_table_rows(issue),
            cell_style: {border_color: "FFFFFF", inline_format: true}
          )
        t.draw
        p.font "Helvetica"
        p.move_down 20
        end
        p.font "Helvetica"

        p.start_new_page unless (issue_index+1) == n_issues
        issue_index += 1
      end
    end
    p.render
  end

end

def prawn_table_rows(issue)
  table_rows = []

  issue.images.in_groups_of(2).each_with_index do |images, index1|
    table_row = images.collect do |image|
      if image
        file_path = image.src_url(:main)
        prawn_table_image(file_path)
      else
        ''
      end
    end
    alphabet = ('a'..'z').to_a
    index2 = -1
    table_rows << images.collect{ |image| "<b>Image-#{image.issue.issue_number}#{alphabet[index1*2+(index2+=1)]}</b>: <i>#{image.caption}</i>" if image }
    table_rows << table_row
    table_rows << [' ', ' ']
  end

  table_rows
end

# ▼

def prawn_table_image(file_path)
  begin
    image_file = open(file_path)
    {image: image_file, scale: 0.5}
  rescue
    "[image missing]"
  end
end
