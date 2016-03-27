class RenameAreasToGroups < ActiveRecord::Migration
  def up
    rename_table :areas, :groups
  end
  def down
    rename_table :groups, :areas
  end
end
