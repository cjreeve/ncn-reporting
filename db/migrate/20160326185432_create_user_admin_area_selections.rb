class CreateUserAdminAreaSelections < ActiveRecord::Migration
  def change
    create_table :user_admin_area_selections do |t|
      t.references :user, index: true, foreign_key: true
      t.references :administrative_area, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
