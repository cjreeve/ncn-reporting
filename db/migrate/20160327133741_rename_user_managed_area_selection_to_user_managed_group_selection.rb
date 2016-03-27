class RenameUserManagedAreaSelectionToUserManagedGroupSelection < ActiveRecord::Migration
  def up
    rename_table :user_managed_area_selections, :user_managed_group_selections
  end
  def down
    rename_table :user_managed_group_selections, :user_managed_area_selections
  end
end
