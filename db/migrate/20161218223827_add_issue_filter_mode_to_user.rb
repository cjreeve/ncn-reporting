class AddIssueFilterModeToUser < ActiveRecord::Migration
  def change
    add_column :users, :issue_filter_mode, :string
  end
end
