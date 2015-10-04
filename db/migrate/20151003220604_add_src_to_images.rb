class AddSrcToImages < ActiveRecord::Migration
  def change
    add_column :images, :src, :string
  end
end
