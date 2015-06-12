json.array!(@issues) do |issue|
  json.extract! issue, :id, :issue_number, :title, :description, :priority, :reported_at, :completed_at
  json.url issue_url(issue, format: :json)
end
