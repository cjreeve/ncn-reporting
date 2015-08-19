class AddSlugToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :slug, :string, null: false, default: ''
    add_index :routes, :slug
  end
end
