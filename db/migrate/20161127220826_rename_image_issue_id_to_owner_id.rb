class RenameImageIssueIdToOwnerId < ActiveRecord::Migration
  def change
    rename_column :images, :issue_id, :owner_id
  end
end
