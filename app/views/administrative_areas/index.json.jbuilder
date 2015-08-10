json.array!(@administrative_areas) do |administrative_area|
  json.extract! administrative_area, :id, :name, :short_name
  json.url administrative_area_url(administrative_area, format: :json)
end
