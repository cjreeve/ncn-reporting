class AddUrlFieldToIssues < ActiveRecord::Migration
  def up
    add_column :issues, :url, :string
  end
  def down
    drop_column :issues, :url
  end
end
