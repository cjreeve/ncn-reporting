class RemoveNameIndexFromRoutes < ActiveRecord::Migration
  def change
    if index_exists? :routes, :name
      remove_index :routes, :name
    end
  end
end
