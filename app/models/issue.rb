class Issue < ActiveRecord::Base

  attr_accessor :coordinate
  
  before_validation :set_issue_number
  before_validation :coordinate_to_latlng

  # def coordinate
  #   "#{self.lat}, #{self.lng}"
  # end
  
  private
  
  def set_issue_number
    self.issue_number = Issue.last.try(:issue_number).to_i + 1 unless self.issue_number.present?
  end

  def coordinate_to_latlng
    self.lat = self.coordinate.split(/[\s,]+/)[0]
    self.lng = self.coordinate.split(/[\s,]+/)[1]
  end
end
