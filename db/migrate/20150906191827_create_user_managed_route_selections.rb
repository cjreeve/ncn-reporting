class CreateUserManagedRouteSelections < ActiveRecord::Migration
  def change
    create_table :user_managed_route_selections do |t|
      t.references :user, index: true
      t.references :route, index: true

      t.timestamps
    end
  end
end
