class Issue < ActiveRecord::Base
  attr_accessor :coordinate

  belongs_to :route
  belongs_to :area
  belongs_to :administrative_area
  has_many :images, dependent: :destroy
  has_many :comments
  has_many :issue_label_selections
  has_many :labels, through: :issue_label_selections
  belongs_to :category
  belongs_to :problem
  belongs_to :user
  belongs_to :editor, class_name: "User"

  accepts_nested_attributes_for(:images, allow_destroy: true, reject_if:  proc { |a| a[:url].blank? && a[:src].blank? && a[:caption].blank? })
  
  PRIORITY = {
    1 => 'low',
    2 => 'medium',
    3 => 'high'
  }
  
  before_validation :load_coordinate_string
  before_validation :set_issue_number
  before_validation :set_priority
  before_validation :set_title
  before_validation :set_edited_at

  validates :title, length: { in: 2..30, message: '- the problem must be between 2 and 30 characters'}
  validates :url, length: { in: 0..1000, message: '- the url must be less than 1000 characters'}

  after_validation :coordinate_to_latlng

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

  after_validation :reverse_geocode

  state_machine :state, initial: :draft do
    event :submit do
      transition draft: :submitted
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
    self.area.present? &&
    self.state_events.include?(:submit)
  end

  def publishable?
    self.valid_coordinate? &&
    self.route.present? &&
    self.area.present?
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
    self.lng.present? && (self.lng > -11.0 && self.lng < 2.0) &&
    self.lat.present? && (self.lat > 49.0 &&  self.lat < 61.0)
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
    self.category.name + ' - ' + the_problem
  end

  def latitude
    self.lat
  end

  def longitude
    self.lng
  end

  def get_address_component(results, types)
    address_component = results.collect{ |r|
      r.address_components.find{ |c|
        types.all?{ |t| c["types"].include?(t) }
      }.try(:[], "short_name")
    }.compact.first
    address_component ||= ""
  end

  def get_location_name(results)
    location_name = get_address_component(results, ["neighborhood"])
    if location_name.blank?
      location_name = get_address_component(results, ["locality"])
      if location_name.blank? || location_name == "London"
        location_name = get_address_component(results, ["route"])
      end
    end
    location_name
  end

  def get_admin_area(results)
    admin_area = get_address_component(results, ["administrative_area_level_3"])
    if admin_area.blank?
      admin_area = get_address_component(results, ["administrative_area_level_2"])
    end
    admin_area
  end

  def find_group_from_coordinate
    if self.area.blank? && self.administrative_area.area.present?
      self.area = self.administrative_area.area
    end
  end
  
  private

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
    if self.problem_id.present? && self.priority.blank?
      self.priority = Problem.find(self.problem_id).default_priority
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
       "area",
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
        issue_values << (issue.area ? issue.area.name : '')
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
end
