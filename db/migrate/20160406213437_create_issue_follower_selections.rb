class CreateIssueFollowerSelections < ActiveRecord::Migration
  def change
    create_table :issue_follower_selections do |t|
      t.references :issue, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
