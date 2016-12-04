# encoding: utf-8
class ImageUploader < SiteUploader

  def store_dir
    "#{ Rails.env }/images/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  process :rotate_img

  def rotate_img
    manipulate! do |img|
      img.rotate model.rotation.to_s if model.rotation.present? && !model.rotation.zero?
      img #returns the manipulated image
    end
  end


  version :small_thumb do
    process resize_to_fill: [100, 100]
  end

  version :thumb do
    process resize_to_fill: [150, 150]
  end

  version :main do
    process resize_to_fit: [468, 1000]
  end

  version :zoom do
    process resize_to_fit: [1000, 1000]
  end

end
