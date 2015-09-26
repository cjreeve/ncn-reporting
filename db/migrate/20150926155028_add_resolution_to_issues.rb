class AddResolutionToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :resolution, :string, index: true
  end
end
