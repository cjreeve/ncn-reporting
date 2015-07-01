class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :problems, :name, unique: true
  end
end
