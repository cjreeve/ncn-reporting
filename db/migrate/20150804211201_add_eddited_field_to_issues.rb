class AddEdditedFieldToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :edited_at, :datetime, null: false, default: DateTime.now
  end
end
