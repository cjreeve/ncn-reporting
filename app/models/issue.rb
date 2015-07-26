class Issue < ActiveRecord::Base
  attr_accessor :coordinate

  belongs_to :route
  belongs_to :area
  has_many :images
  belongs_to :category
  belongs_to :problem
  belongs_to :user

  accepts_nested_attributes_for(:images, allow_destroy: true, reject_if: :all_blank)

  PRIORITY = {
    1 => 'low',
    2 => 'medium',
    3 => 'high'
  }
  
  before_validation :set_issue_number
  before_validation :set_priority
  before_validation :set_title

  validates :title, presence: true
  validates :problem, presence: true

  after_validation :coordinate_to_latlng

  state_machine :state, initial: :draft do
    event :publish do
      transition draft: :open
    end
    event :archive do
      transition open: :archived
    end
    event :resolve do
      transition [:open, :reopened] => :resolved
    end
    event :reject do
      transition [:open, :reopened] => :unsolveable
    end
    event :close do
      transition [:resolved, :unsolveable] => :closed
    end
    event :reopen do
      transition [:unsolveable, :resolved, :closed] => :reopened, archived: :open
    end
  end

  def publishable?
    self.state_events.include?(:publish)
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
  
  private
  
  def set_issue_number
    self.issue_number = Issue.last.try(:issue_number).to_i + 1 unless self.issue_number.present?
  end

  def coordinate_to_latlng
    if self.coordinate.present?
      self.lat = self.coordinate.split(/[\s,]+/)[0]
      self.lng = self.coordinate.split(/[\s,]+/)[1]
    end
  end

  def set_priority
    if self.problem_id.present?
      self.priority = Problem.find(self.problem_id).default_priority
    end
  end

  def set_title
    problem = Problem.find(self.problem_id) if self.problem_id
    self.title = problem.name unless problem.name == 'other'
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
end
