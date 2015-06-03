class AddStateToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :state, :string, null: false, default: 'draft'
    add_index :issues, :state
  end
  def down
    remove_column :issues, :state
  end
end
