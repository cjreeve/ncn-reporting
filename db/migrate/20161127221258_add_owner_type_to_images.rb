class AddOwnerTypeToImages < ActiveRecord::Migration
  def change
    add_column :images, :owner_type, :string
    add_index :images, :owner_type
  end
end
