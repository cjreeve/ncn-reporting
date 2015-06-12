class ChangeIssueColumnsForReportedAndCompletedTimes < ActiveRecord::Migration
  def up
    rename_column :issues, :time_reported, :reported_at
    rename_column :issues, :time_completed, :completed_at
  end
  def down
    rename_column :issues, :reported_at, :time_reported
    rename_column :issues, :completed_at, :time_completed
  end
end
