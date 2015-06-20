class AddRouteRefToIssues < ActiveRecord::Migration
  def change
    add_reference :issues, :route, index: true
  end
end
