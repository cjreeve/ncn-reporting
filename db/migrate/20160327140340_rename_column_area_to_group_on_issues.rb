class RenameColumnAreaToGroupOnIssues < ActiveRecord::Migration
  def up
    rename_column :issues, :area_id, :group_id
  end
  def down
    rename_column :issues, :group_id, :area_id
  end
end
