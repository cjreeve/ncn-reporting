class AddIsAdminToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_admin, :boolean, index:true, default: false
  end
end
