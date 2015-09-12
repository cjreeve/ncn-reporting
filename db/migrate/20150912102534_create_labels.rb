class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :name, null: false, default: '', unique: true, index: true

      t.timestamps
    end
  end
end
