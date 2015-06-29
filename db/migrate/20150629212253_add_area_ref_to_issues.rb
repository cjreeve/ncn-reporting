class AddAreaRefToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :area, index: true
  end
end
