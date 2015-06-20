class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.string :name, null: false, default: ''

      t.timestamps
    end
    add_index :routes, :name, unique: true
  end
end
