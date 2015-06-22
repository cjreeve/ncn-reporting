json.array!(@images) do |image|
  json.extract! image, :id, :url, :caption, :issue_id
  json.url image_url(image, format: :json)
end
