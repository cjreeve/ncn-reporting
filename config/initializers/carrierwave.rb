# encoding: UTF-8

CarrierWave.configure do |config|
  unless Rails.env == 'development'
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: 'eu-west-1'
    }
    config.fog_directory = ENV['S3_BUCKET_NAME']
  end
end