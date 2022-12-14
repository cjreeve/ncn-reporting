class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :url
      t.string :caption
      t.references :issue, index: true

      t.timestamps
    end
  end
end
