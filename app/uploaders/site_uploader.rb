# encoding: utf-8
class SiteUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper # not sure if it is required

  if Rails.env == 'development'
    storage :file
  else
    storage :fog
  end

end
