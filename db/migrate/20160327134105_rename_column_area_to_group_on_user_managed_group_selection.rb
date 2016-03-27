class RenameColumnAreaToGroupOnUserManagedGroupSelection < ActiveRecord::Migration
  def up
    rename_column :user_managed_group_selections, :area_id, :group_id
  end
  def down
    rename_column :user_managed_group_selections, :group_id, :area_id
  end
end
