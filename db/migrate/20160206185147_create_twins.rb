class CreateTwins < ActiveRecord::Migration
  def change
    create_table :twins do |t|
      t.references :issue, index: true, foreign_key: true
      t.references :twinned_issue, index: true

      t.timestamps null: false
    end

    add_foreign_key :twins, :issues, column: :twinned_issue_id
    add_index :twins, [:issue_id, :twinned_issue_id], unique: true
  end
end
