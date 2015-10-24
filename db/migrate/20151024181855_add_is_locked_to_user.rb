class AddIsLockedToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_locked, :boolean, index: true, default: false
  end
end
