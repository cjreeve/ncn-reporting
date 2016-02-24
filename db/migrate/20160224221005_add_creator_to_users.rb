class AddCreatorToUsers < ActiveRecord::Migration
  def change
    add_column :users, :creator_id, :integer
    add_index :users, :creator_id
  end
end
