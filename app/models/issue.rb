class Issue < ActiveRecord::Base

  attr_accessor :coordinate
  
  before_validation :set_issue_number
  before_validation :coordinate_to_latlng

  state_machine :state, initial: :draft do
    event :publish do
      transition [:draft, :archived] => :open
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
