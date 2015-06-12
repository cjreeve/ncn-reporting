class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer :issue_number, null: false
      t.string :title, null: false, default: ''
      t.text :description, null: false, default: ''
      t.integer :priority
      t.datetime :reported_at
      t.datetime :completed_at

      t.timestamps
    end
    add_index :issues, :issue_number, unique: true
    add_index :issues, :reported_at
    add_index :issues, :completed_at
  end
end
