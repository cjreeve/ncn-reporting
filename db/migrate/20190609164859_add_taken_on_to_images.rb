class AddTakenOnToImages < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :taken_on, :date
    add_index :images, :taken_on
  end
end
