class AddAreaToAdministrativeAreas < ActiveRecord::Migration
  def change
    add_reference :administrative_areas, :area, index: true
  end
end
