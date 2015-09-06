class CreateUserManagedAreaSelections < ActiveRecord::Migration
  def change
    create_table :user_managed_area_selections do |t|
      t.references :user, index: true
      t.references :area, index: true

      t.timestamps
    end
  end
end
