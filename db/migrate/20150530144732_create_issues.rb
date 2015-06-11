class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :issue_number, null: false
      t.string :title, null: false, default: ''
      t.text :description, null: false, default: ''
      t.integer :priority
      t.datetime :time_reported
      t.datetime :time_completed

      t.timestamps
    end
    add_index :issues, :issue_number, unique: true
    add_index :issues, :time_reported
    add_index :issues, :time_completed
  end
end