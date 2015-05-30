json.array!(@issues) do |issue|
  json.extract! issue, :id, :issue_number, :title, :description, :priority, :time_reported, :time_completed
  json.url issue_url(issue, format: :json)
end
