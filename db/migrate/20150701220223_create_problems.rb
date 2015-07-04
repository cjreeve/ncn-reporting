class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name, null: false, default: ''
      t.integer :default_priority

      t.timestamps
    end
    add_index :problems, :name, unique: true
  end
end
