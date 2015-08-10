class DropAdministrativeAreaFromIssues < ActiveRecord::Migration
  def change
    remove_column :issues, :administrative_area
  end
end
