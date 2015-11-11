json.array!(@regions) do |region|
  json.extract! region, :id, :name, :lat, :lng, :map_zoom, :email, :email_name, :notifications_sent_at
  json.url region_url(region, format: :json)
end
