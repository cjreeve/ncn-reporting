class AddCoordinateToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :lat, :float
    add_index :segments, :lat
    add_column :segments, :lng, :float
    add_index :segments, :lng
  end
end
