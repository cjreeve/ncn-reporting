json.array!(@pages) do |page|
  json.extract! page, :id, :name, :slug, :content, :role
  json.url page_url(page, format: :json)
end
