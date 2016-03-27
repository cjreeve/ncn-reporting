class AddRegionToGroups < ActiveRecord::Migration
  def change
    add_reference :groups, :region, index: true, foreign_key: true
  end
end
