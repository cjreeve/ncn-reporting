class AddCoordinateToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :location_name, :string
    add_column :issues, :lat, :float
    add_column :issues, :lng, :float
    add_index :issues, :location_name
    add_index :issues, :lat
    add_index :issues, :lng
  end
  def down
    remove_column :issues, :location_name
    remove_column :issues, :lat
    remove_column :issues, :lng
  end
end
