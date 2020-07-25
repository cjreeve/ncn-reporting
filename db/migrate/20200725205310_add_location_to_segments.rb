class AddLocationToSegments < ActiveRecord::Migration[5.2]
  def change
    add_column :segments, :location, :string
  end
end
