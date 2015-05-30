class Issue < ActiveRecord::Base
  
  before_validation :set_issue_number
  
  private
  
  def set_issue_number
    self.issue_number = Issue.last.try(:issue_number).to_i + 1
  end
end
