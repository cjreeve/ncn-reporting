class AddProblemToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :problem, index: true
  end
end
