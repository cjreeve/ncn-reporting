class ChangeImageUrlToText < ActiveRecord::Migration
  def up
    change_column :images, :url, :text
  end

  def down
    # https://gist.github.com/jenheilemann/6308068
    # create a temporary column to hold the truncated values
    # we'll rename this later to the original column name
    add_column :images, :temp_url, :string
    
    # use #find_each to load only part of the table into memory
    Image.find_each do |image|
      temp_url = image.url
      
      # test if the new value will fit into the truncated field
      if image.url.length > 255
        temp_url = image.url[0,254]
      end
      
      # use #update_column because it skips validations AND callbacks
      image.update_column(:temp_url, temp_url)
    end
    
    # delete the old column since we have all the data safe in the
    # temp_description
    remove_column :images, :url
  
    # rename the temp_column to our original column name
    rename_column :images, :temp_url, :url
  end
end
