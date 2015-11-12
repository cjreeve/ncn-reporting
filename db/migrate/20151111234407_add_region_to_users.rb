class AddRegionToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :region, index: true
  end
end
