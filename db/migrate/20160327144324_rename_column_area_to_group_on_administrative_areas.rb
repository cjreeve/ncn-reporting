class RenameColumnAreaToGroupOnAdministrativeAreas < ActiveRecord::Migration
  def up
    rename_column :administrative_areas, :area_id, :group_id
  end
  def down
    rename_column :administrative_areas, :group_id, :area_id
  end
end
