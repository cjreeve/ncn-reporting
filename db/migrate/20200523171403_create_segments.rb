class CreateSegments < ActiveRecord::Migration[5.2]
  def change
    create_table :segments do |t|
      t.string :name
      t.references :route, foreign_key: true
      t.references :administrative_area, foreign_key: true
      t.integer :last_checked_by_id
      t.datetime :last_checked_at
      t.text :track

      t.timestamps
    end
    add_index :segments, :name
    add_index :segments, :last_checked_by_id
    add_index :segments, :last_checked_at
  end
end
