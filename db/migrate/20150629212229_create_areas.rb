class CreateAreas < ActiveRecord::Migration
  def up
    create_table :areas do |t|
      t.string :name, null: false, default: ''

      t.timestamps
    end
    add_index :areas, :name
  end
  def down
    drop_table :areas
  end
end
