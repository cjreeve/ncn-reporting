class Issue < ActiveRecord::Base
  
  before_validation :set_issue_number
  
  private
  
  def set_issue_number
    self.issue_number = Issue.last.issue_number + 1
  end
end
