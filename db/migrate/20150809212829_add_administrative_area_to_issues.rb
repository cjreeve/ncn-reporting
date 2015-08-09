class AddAdministrativeAreaToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :administrative_area, :string
  end
end
