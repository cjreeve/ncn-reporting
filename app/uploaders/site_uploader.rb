# encoding: utf-8
class SiteUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick
  include Sprockets::Rails::Helper # not sure if it is required

  if %w(development test).include? Rails.env
    storage :file
  else
    storage :fog
  end

  unless Rails.env.production?
    def remove!
    end
  end

end
