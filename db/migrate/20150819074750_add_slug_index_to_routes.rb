class AddSlugIndexToRoutes < ActiveRecord::Migration
  def up
    unless index_exists? :routes, :slug
      add_index :routes, :slug, unique: true
    end
  end
  def down
    if index_exists? :routes, :slug
      remove_index :routes, :slug
    end
  end
end
