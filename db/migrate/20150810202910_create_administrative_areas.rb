class CreateAdministrativeAreas < ActiveRecord::Migration
  def change
    create_table :administrative_areas do |t|
      t.string :name, null: false
      t.string :short_name

      t.timestamps
    end
    add_index :administrative_areas, :name, unique: true
    add_index :administrative_areas, :short_name, unique: true
  end
end
