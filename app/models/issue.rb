class Issue < ActiveRecord::Base

  attr_accessor :coordinate

  belongs_to :route
  has_many :images

  accepts_nested_attributes_for(:images, allow_destroy: true, reject_if: :all_blank)
  
  before_validation :set_issue_number

  validates :title, presence: true

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
end
