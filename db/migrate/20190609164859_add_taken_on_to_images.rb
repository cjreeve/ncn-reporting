class AddTakenOnToImages < ActiveRecord::Migration
  def change
    add_column :images, :taken_on, :date
    add_index :images, :taken_on
  end
end
