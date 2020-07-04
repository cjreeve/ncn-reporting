class AddRegionToSegments < ActiveRecord::Migration[5.2]
  def change
    add_reference :segments, :region, foreign_key: true
  end
end
