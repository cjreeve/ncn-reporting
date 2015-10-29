class AddVisitedUpdatesAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :visited_updates_at, :datetime, null: false, default: DateTime.now - 10.days
  end
end
