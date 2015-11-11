class CreateRegions < ActiveRecord::Migration
  def change
    create_table :regions do |t|
      t.string :name, null:false
      t.float :lat, full:false, default: 0
      t.float :lng, null:false, default: 0
      t.integer :map_zoom, null: false, default: 11
      t.string :email
      t.string :email_name
      t.datetime :notifications_sent_at

      t.timestamps
    end
  end
end
