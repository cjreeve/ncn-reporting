# encoding: utf-8
class ImageUploader < SiteUploader

  def store_dir
    "#{ Rails.env }/images/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process resize_to_fill: [150, 150]
  end

  version :main do
    process resize_to_fit: [468, 620]
  end

  version :zoom do
    process resize_to_fit: [1000, 1000]
  end

end
