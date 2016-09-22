class AddRotationToImages < ActiveRecord::Migration
  def change
    add_column :images, :rotation, :integer
  end
end
